From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PFKEY] Set family for state selector
Date: Thu, 27 May 2004 20:44:45 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040527104445.GA24976@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="SLDf9lqlvOQaIe6s"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--SLDf9lqlvOQaIe6s
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

As the comment in the code suggests, nobody really uses this so nobody
will notice the difference :) Still, let's make it correct while we're
at it.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--SLDf9lqlvOQaIe6s
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/key/af_key.c 1.58 vs edited =====
--- 1.58/net/key/af_key.c	2004-05-26 06:09:13 +10:00
+++ edited/net/key/af_key.c	2004-05-27 20:37:08 +10:00
@@ -1059,7 +1059,7 @@
 		struct sadb_address *addr = ext_hdrs[SADB_EXT_ADDRESS_PROXY-1];
 
 		/* Nobody uses this, but we try. */
-		pfkey_sadb_addr2xfrm_addr(addr, &x->sel.saddr);
+		x->sel.family = pfkey_sadb_addr2xfrm_addr(addr, &x->sel.saddr);
 		x->sel.prefixlen_s = addr->sadb_address_prefixlen;
 	}
 

--SLDf9lqlvOQaIe6s--
