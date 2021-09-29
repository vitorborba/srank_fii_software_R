if (!require("BatchGetSymbols"))       install.packages("BatchGetSymbols")
if (!require("rvest"))                 install.packages("rvest")


############################################################
#Parte inspirada no codigo do canal OutspokenMarket
############################################################

#Insira a URL alvo - Ajuste Derivativos - Pregao
url <- 'https://www.fundamentus.com.br/fii_resultado.php'

#Le o codigo HTML da url indicada
site <- read_html(url)

#Escolhe qual o elemento HTML para coletar - resultado em HTML
info_Ajuste_HTML <- html_nodes(site,'table')

#Converte o HTML para texto
info_Ajuste <- html_text(info_Ajuste_HTML)

#Visualizacao do Texto
head(info_Ajuste,20)

#Como melhorar a visualiza√ßao e captura das tabelas?
head(info_Ajuste_HTML)

lista_tabela <- site %>%
  html_nodes("table") %>%
  html_table(fill = TRUE)

#Visualiza√ßao
str(lista_tabela)

#head(lista_tabela[[1]], 10)

#View(lista_tabela[[1]])

#Atribui√ßao
dd <- lista_tabela[[1]]
############################################################


############################################################
# Adaptacoes para o cenario de FII_s
############################################################
dados <- dd
dim(dados)
#View(dados)
dados <- as.data.frame(dados)

############################################
# Renomeando as variaveis
############################################
names(dados) <- c("papel","segmento","cotacao","ffo_yield","dividend_yield","p_vp","valor_de_mercado","liquidez","qtd_de_imoveis","preco_do_m2","aluguel_por_m2","cap_rate","vacancia_media","endereco")

###########################
#Excluindo endereco
###########################
dados <- dados[1:13]
str(dados)

#########################################
#Removendo percentual do dividend_yield
#########################################
dados$dividend_yield <- gsub("\\%","",dados$dividend_yield)

#########################################
#Removendo percentual da liquidez
#########################################
dados$liquidez <- gsub("\\.","",dados$liquidez)

#gsub("\\.(?=[^.]*\\.)", "" dados$liquidez, perl=TRUE)


#########################################
# Selecionando variaveis necessarias
#########################################
dados <- dados %>% select(papel, cotacao ,p_vp, dividend_yield,liquidez)

head(dados)
str(dados)

#########################################
# Passando para numerica as va's
#########################################
dados$liquidez       <- as.numeric(dados$liquidez)
dados$cotacao        <- as.numeric(gsub(",", ".", gsub("\\.", "", dados$cotacao)))
dados$p_vp           <- as.numeric(gsub(",", ".", gsub("\\.", "", dados$p_vp)))
dados$dividend_yield <- as.numeric(gsub(",", ".", gsub("\\.", "", dados$dividend_yield)))

#########################################
# Filtros S-rank
#########################################
# Filtro de 200 mil
# Filtro de Tipo tirar (desenvolvimento e incorporaÁ„o)
# Filtro de estabilidade (ver Yield)
# Filtro de idade, ao menos 1 ano de idade


#########################################
# Filtro liquidez
#########################################
dados <- dados[dados$liquidez >= 200000, ]


#########################################
#Ordenando por p_vp
#########################################
dados <- dados[order(dados$p_vp),]
dados$rank_p_vp <- as.numeric(seq(1:nrow(dados)))


#########################################
#Ordenando por dividend_yield
#########################################
dados <- dados[order(-dados$dividend_yield),]
dados$rank_dividend_yield <- as.numeric(seq(1:nrow(dados)))


#########################################
#Somar os Rankings
#########################################
dados$rank_soma <- dados$rank_p_vp + dados$rank_dividend_yield


#########################################
#Ordenando pelo o novo rank soma
#########################################
dados <- dados[order(dados$rank_soma),]

dados$rank_ordem <- as.numeric(seq(1:nrow(dados)))

#########################################
# Retirando fundos que n„o podem estar 
#########################################




dim(dados)
str(dados)
head(dados)
tail(dados)
View(dados)



