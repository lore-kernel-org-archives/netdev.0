From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [ATM] Fix flags type in lec_arp_expire_vcc
Date: Thu, 27 Jan 2005 10:38:20 +1100
Message-ID: <20050126233820.GA24422@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Q68bSM7Ycu6FN28Q"
Cc: Chas Williams <chas@cmf.nrl.navy.mil>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Q68bSM7Ycu6FN28Q
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

The variable flags in lec_arp_expire_vcc should be of type
unsigned long and not unsigned.  The following patch fixes
that typo.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--Q68bSM7Ycu6FN28Q
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=q

===== net/atm/lec.c 1.45 vs edited =====
--- 1.45/net/atm/lec.c	2005-01-19 07:59:15 +11:00
+++ edited/net/atm/lec.c	2005-01-27 10:33:29 +11:00
@@ -1818,7 +1818,7 @@
 static void
 lec_arp_expire_vcc(unsigned long data)
 {
-	unsigned flags;
+	unsigned long flags;
         struct lec_arp_table *to_remove = (struct lec_arp_table*)data;
         struct lec_priv *priv = (struct lec_priv *)to_remove->priv;
         struct lec_arp_table *entry = NULL;

--Q68bSM7Ycu6FN28Q--
