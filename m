From: Harsh Jain <harsh@chelsio.com>
Subject: [PATCH 5/8] crypto:chcr: Change cra_flags for cipher algos
Date: Fri, 27 Jan 2017 16:09:09 +0530
Message-ID: <19591395286ea8addca8affa595eabd951fda7ff.1485501429.git.harsh@chelsio.com>
References: <cover.1485501428.git.harsh@chelsio.com>
Cc: Harsh Jain <harsh@chelsio.com>
To: herbert@gondor.apana.org.au, linux-crypto@vger.kernel.org,
        hariprasad@chelsio.com, netdev@vger.kernel.org, arjun@chelsio.com,
        atul.gupta@chelsio.com
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <cover.1485501428.git.harsh@chelsio.com>
In-Reply-To: <cover.1485501428.git.harsh@chelsio.com>
References: <cover.1485501428.git.harsh@chelsio.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
