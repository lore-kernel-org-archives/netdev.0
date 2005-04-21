From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NET] Add missing newline for skb_*_panic
Date: Thu, 21 Apr 2005 15:08:15 +1000
Message-ID: <20050421050815.GA23133@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="9jxsPFA5p3P2qPhR"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--9jxsPFA5p3P2qPhR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

Here is a trivial patch to make the skb_under_panic/skb_over_panic
messages to look nicer.  As it is their printk is joined onto the
first line of the BUG output because of a missing newline.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--9jxsPFA5p3P2qPhR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/core/skbuff.c 1.44 vs edited =====
--- 1.44/net/core/skbuff.c	2005-03-12 07:32:26 +11:00
+++ edited/net/core/skbuff.c	2005-04-21 15:06:12 +10:00
@@ -86,7 +86,7 @@
  */
 void skb_over_panic(struct sk_buff *skb, int sz, void *here)
 {
-	printk(KERN_INFO "skput:over: %p:%d put:%d dev:%s",
+	printk(KERN_INFO "skput:over: %p:%d put:%d dev:%s\n",
 		here, skb->len, sz, skb->dev ? skb->dev->name : "<NULL>");
 	BUG();
 }
@@ -102,7 +102,7 @@
 
 void skb_under_panic(struct sk_buff *skb, int sz, void *here)
 {
-	printk(KERN_INFO "skput:under: %p:%d put:%d dev:%s",
+	printk(KERN_INFO "skput:under: %p:%d put:%d dev:%s\n",
                here, skb->len, sz, skb->dev ? skb->dev->name : "<NULL>");
 	BUG();
 }

--9jxsPFA5p3P2qPhR--
