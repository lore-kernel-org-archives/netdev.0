From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 2/3] [IPSEC]: Allow async algorithms
Date: Tue, 11 Dec 2007 12:23:44 +0800
Message-ID: <E1J1wem-0002r3-00@gondolin.me.apana.org.au>
References: <20071211042312.GA10911@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2272 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751496AbXLKEXr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2007 23:23:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[IPSEC]: Allow async algorithms

Now that ESP uses authenc we can turn on the support for async algorithms
in IPsec.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/xfrm/xfrm_algo.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/xfrm/xfrm_algo.c b/net/xfrm/xfrm_algo.c
index 1686f64..ae34a12 100644
--- a/net/xfrm/xfrm_algo.c
+++ b/net/xfrm/xfrm_algo.c
@@ -358,21 +358,21 @@ static const struct xfrm_algo_list xfrm_aalg_list = {
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
