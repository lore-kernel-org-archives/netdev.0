From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [1/2] Use xfrm4_rcv in xfrm4_tunnel
Date: Thu, 19 Aug 2004 21:38:41 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040819113841.GA13872@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="h31gzZEtNLTqOjlF"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--h31gzZEtNLTqOjlF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

This is a trivial patch to use xfrm4_rcv in xfrm4_tunnel.  It doesn't
need the extra argument provided by xfrm4_rcv_encap.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--h31gzZEtNLTqOjlF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=q

===== net/ipv4/xfrm4_tunnel.c 1.17 vs edited =====
--- 1.17/net/ipv4/xfrm4_tunnel.c	2004-08-14 20:59:43 +10:00
+++ edited/net/ipv4/xfrm4_tunnel.c	2004-08-19 21:34:39 +10:00
@@ -68,7 +68,7 @@
 	if (handler && handler->handler(skb) == 0)
 		return 0;
 
-	return xfrm4_rcv_encap(skb, 0);
+	return xfrm4_rcv(skb);
 }
 
 static void ipip_err(struct sk_buff *skb, u32 info)

--h31gzZEtNLTqOjlF--
