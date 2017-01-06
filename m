From: Harsh Jain <harsh@chelsio.com>
Subject: [PATCH v1 5/8] crypto:chcr: Change cra_flags for cipher algos
Date: Fri,  6 Jan 2017 14:01:36 +0530
Message-ID: <49d449c46db820bbffad65ad630c471339fc00fd.1483599449.git.harsh@chelsio.com>
References: <cover.1483599449.git.harsh@chelsio.com>
Cc: Harsh Jain <harsh@chelsio.com>
To: hariprasad@chelsio.com, netdev@vger.kernel.org,
        herbert@gondor.apana.org.au, linux-crypto@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:45996 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S939663AbdAFIc1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 03:32:27 -0500
In-Reply-To: <cover.1483599449.git.harsh@chelsio.com>
In-Reply-To: <cover.1483599449.git.harsh@chelsio.com>
References: <cover.1483599449.git.harsh@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change cipher algos flags to CRYPTO_ALG_TYPE_ABLKCIPHER.

Signed-off-by: Harsh Jain <harsh@chelsio.com>
---
 drivers/crypto/chelsio/chcr_algo.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/crypto/chelsio/chcr_algo.c b/drivers/crypto/chelsio/chcr_algo.c
index d335943..21fc04c 100644
--- a/drivers/crypto/chelsio/chcr_algo.c
+++ b/drivers/crypto/chelsio/chcr_algo.c
@@ -171,7 +171,7 @@ int chcr_handle_resp(struct crypto_async_request *req, unsigned char *input,
 		}
 		break;
 
-	case CRYPTO_ALG_TYPE_BLKCIPHER:
+	case CRYPTO_ALG_TYPE_ABLKCIPHER:
 		ctx_req.req.ablk_req = (struct ablkcipher_request *)req;
 		ctx_req.ctx.ablk_ctx =
 			ablkcipher_request_ctx(ctx_req.req.ablk_req);
@@ -2492,7 +2492,7 @@ static int chcr_aead_op(struct aead_request *req,
 			.cra_name		= "cbc(aes)",
 			.cra_driver_name	= "cbc-aes-chcr",
 			.cra_priority		= CHCR_CRA_PRIORITY,
-			.cra_flags		= CRYPTO_ALG_TYPE_BLKCIPHER |
+			.cra_flags		= CRYPTO_ALG_TYPE_ABLKCIPHER |
 				CRYPTO_ALG_ASYNC,
 			.cra_blocksize		= AES_BLOCK_SIZE,
 			.cra_ctxsize		= sizeof(struct chcr_context)
@@ -2519,7 +2519,7 @@ static int chcr_aead_op(struct aead_request *req,
 			.cra_name		= "xts(aes)",
 			.cra_driver_name	= "xts-aes-chcr",
 			.cra_priority		= CHCR_CRA_PRIORITY,
-			.cra_flags		= CRYPTO_ALG_TYPE_BLKCIPHER |
+			.cra_flags		= CRYPTO_ALG_TYPE_ABLKCIPHER |
 				CRYPTO_ALG_ASYNC,
 			.cra_blocksize		= AES_BLOCK_SIZE,
 			.cra_ctxsize		= sizeof(struct chcr_context) +
-- 
1.8.2.3
