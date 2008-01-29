From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 2/3] [IPSEC]: Allow async algorithms
Date: Tue, 29 Jan 2008 14:11:24 +1100
Message-ID: <E1JJgse-0003Yi-00@gondolin.me.apana.org.au>
References: <20080129031047.GA13625@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:55849 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754315AbYA2DL1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2008 22:11:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[IPSEC]: Allow async algorithms

Now that ESP uses authenc we can turn on the support for async algorithms
in IPsec.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/xfrm/xfrm_algo.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/xfrm/xfrm_algo.c b/net/xfrm/xfrm_algo.c
--- a/net/xfrm/xfrm_algo.c
+++ b/net/xfrm/xfrm_algo.c
@@ -358,21 +358,21 @@ static const struct xfrm_algo_list xfrm_
 	.algs = aalg_list,
 	.entries = ARRAY_SIZE(aalg_list),
 	.type = CRYPTO_ALG_TYPE_HASH,
-	.mask = CRYPTO_ALG_TYPE_HASH_MASK | CRYPTO_ALG_ASYNC,
+	.mask = CRYPTO_ALG_TYPE_HASH_MASK,
 };
 
 static const struct xfrm_algo_list xfrm_ealg_list = {
 	.algs = ealg_list,
 	.entries = ARRAY_SIZE(ealg_list),
 	.type = CRYPTO_ALG_TYPE_BLKCIPHER,
-	.mask = CRYPTO_ALG_TYPE_MASK | CRYPTO_ALG_ASYNC,
+	.mask = CRYPTO_ALG_TYPE_BLKCIPHER_MASK,
 };
 
 static const struct xfrm_algo_list xfrm_calg_list = {
 	.algs = calg_list,
 	.entries = ARRAY_SIZE(calg_list),
 	.type = CRYPTO_ALG_TYPE_COMPRESS,
-	.mask = CRYPTO_ALG_TYPE_MASK | CRYPTO_ALG_ASYNC,
+	.mask = CRYPTO_ALG_TYPE_MASK,
 };
 
 static struct xfrm_algo_desc *xfrm_find_algo(
