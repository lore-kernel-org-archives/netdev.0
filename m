From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC] Update out-of-date comment in __xfrm_state_delete
Date: Tue, 25 May 2004 22:00:16 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040525120016.GA15487@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="UlVJffcvxoiEqYs2"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--UlVJffcvxoiEqYs2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

The comment at the end of __xfrm_state_delete no longer matches the
status quo.  This patch brings it up-to-date again.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--UlVJffcvxoiEqYs2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/xfrm/xfrm_state.c 1.40 vs edited =====
--- 1.40/net/xfrm/xfrm_state.c	2004-05-25 21:54:27 +10:00
+++ edited/net/xfrm/xfrm_state.c	2004-05-25 21:58:06 +10:00
@@ -221,13 +221,9 @@
 		if (atomic_read(&x->refcnt) > 2)
 			xfrm_flush_bundles();
 
-		/* All xfrm_state objects are created by one of two possible
-		 * paths:
-		 *
-		 * 2) xfrm_state_lookup --> xfrm_state_insert
-		 *
-		 * The xfrm_state_lookup or xfrm_state_alloc call gives a
-		 * reference, and that is what we are dropping here.
+		/* All xfrm_state objects are created by xfrm_state_alloc.
+		 * The xfrm_state_alloc call gives a reference, and that
+		 * is what we are dropping here.
 		 */
 		atomic_dec(&x->refcnt);
 	}

--UlVJffcvxoiEqYs2--
