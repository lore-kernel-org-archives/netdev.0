From: Jamal Hadi Salim <hadi@znyx.com>
Subject: e1000 patchlet
Date: 01 Oct 2004 08:25:37 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1096633537.1041.87.camel@jzny.localdomain>
Reply-To: hadi@znyx.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-5j0yS34gsvXTv80xkOnb"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, john.ronciak@intel.com,
        ganesh.venkatesan@intel.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-5j0yS34gsvXTv80xkOnb
Content-Transfer-Encoding: 7bit
Content-Type: text/plain


 attached

cheers,
jamal

--=-5j0yS34gsvXTv80xkOnb
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=e1000p1
Content-Type: text/plain; name=e1000p1; charset=ISO-8859-1

--- a/drivers/net/e1000/e1000_main.c	2004/10/01 12:09:51	1.1
+++ b/drivers/net/e1000/e1000_main.c	2004/10/01 12:12:48
@@ -1773,7 +1773,6 @@
 	unsigned int mss = 0;
 	int count = 0;
 	unsigned int f;
-	nr_frags = skb_shinfo(skb)->nr_frags;
 	len -= skb->data_len;
 
 	if(unlikely(skb->len <= 0)) {

--=-5j0yS34gsvXTv80xkOnb--
