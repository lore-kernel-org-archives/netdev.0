From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPv4] Kill remnant of ip_nat_dumb
Date: Wed, 22 Sep 2004 14:01:55 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040922040155.GA19302@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="u3/rZRmxL6MmkK24"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--u3/rZRmxL6MmkK24
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

This line in net/ipv4/Makefile was left behind when the rest of the
dumb NAT option was taken out.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--u3/rZRmxL6MmkK24
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv4/Makefile 1.24 vs edited =====
--- 1.24/net/ipv4/Makefile	2004-08-20 00:13:10 +10:00
+++ edited/net/ipv4/Makefile	2004-09-22 13:53:54 +10:00
@@ -11,7 +11,6 @@
 
 obj-$(CONFIG_PROC_FS) += proc.o
 obj-$(CONFIG_IP_MULTIPLE_TABLES) += fib_rules.o
-obj-$(CONFIG_IP_ROUTE_NAT) += ip_nat_dumb.o
 obj-$(CONFIG_IP_MROUTE) += ipmr.o
 obj-$(CONFIG_NET_IPIP) += ipip.o
 obj-$(CONFIG_NET_IPGRE) += ip_gre.o


--u3/rZRmxL6MmkK24--
