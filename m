From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC] Make ah4/esp4/ipcomp depend on INET
Date: Fri, 29 Oct 2004 13:39:00 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041029033900.GA23206@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="wRRV7LY7NUeQGEoC"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--wRRV7LY7NUeQGEoC
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

As it is someone could disable INET and still enable ah4/esp4/ipcomp.
This patch adds the dependency on INET to prevent this.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--wRRV7LY7NUeQGEoC
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv4/Kconfig 1.20 vs edited =====
--- 1.20/net/ipv4/Kconfig	2004-10-27 05:32:28 +10:00
+++ edited/net/ipv4/Kconfig	2004-10-29 13:34:38 +10:00
@@ -301,6 +301,7 @@
 
 config INET_AH
 	tristate "IP: AH transformation"
+	depends on INET
 	select XFRM
 	select CRYPTO
 	select CRYPTO_HMAC
@@ -313,6 +314,7 @@
 
 config INET_ESP
 	tristate "IP: ESP transformation"
+	depends on INET
 	select XFRM
 	select CRYPTO
 	select CRYPTO_HMAC
@@ -326,6 +328,7 @@
 
 config INET_IPCOMP
 	tristate "IP: IPComp transformation"
+	depends on INET
 	select XFRM
 	select INET_TUNNEL
 	select CRYPTO
@@ -338,6 +341,7 @@
 
 config INET_TUNNEL
 	tristate "IP: tunnel transformation"
+	depends on INET
 	select XFRM
 	---help---
 	  Support for generic IP tunnel transformation, which is required by

--wRRV7LY7NUeQGEoC--
