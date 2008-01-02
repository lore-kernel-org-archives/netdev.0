From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC]: Kill duplicate xfrm_policy_flush prototype
Date: Wed, 2 Jan 2008 14:02:11 +1100
Message-ID: <20080102030211.GA31886@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4293 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752993AbYABDCQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jan 2008 22:02:16 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave:

[IPSEC]: Kill duplicate xfrm_policy_flush prototype

For five years we had two xfrm_policy_flush prototypes and every time that
function's signature changed people have been diligently updating both of
them without noticing :)

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 2b6246a..1dbd2f9 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1316,7 +1316,6 @@ extern int xfrm_alloc_spi(struct xfrm_state *x, u32 minspi, u32 maxspi);
 struct xfrm_state * xfrm_find_acq(u8 mode, u32 reqid, u8 proto,
 				  xfrm_address_t *daddr, xfrm_address_t *saddr,
 				  int create, unsigned short family);
-extern int xfrm_policy_flush(u8 type, struct xfrm_audit *audit_info);
 extern int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol);
 extern int xfrm_bundle_ok(struct xfrm_policy *pol, struct xfrm_dst *xdst,
 			  struct flowi *fl, int family, int strict);

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
