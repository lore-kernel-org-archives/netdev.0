From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 4/4] crypto: api - Extend algorithm name limit to 128 bytes
Date: Thu, 06 Apr 2017 16:16:11 +0800
Message-ID: <E1cw2aR-000868-VF@gondobar>
References: <20170406081509.GB30557@gondor.apana.org.au>
To: Alexander Sverdlin <alexander.sverdlin@nokia.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-crypto@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With the new explicit IV generators, we may now exceed the 64-byte
length limit on the algorithm name, e.g., with

	echainiv(authencesn(hmac(sha256-generic),cbc(des3_ede-generic)))

This patch extends the length limit to 128 bytes.

Reported-by: Alexander Sverdlin <alexander.sverdlin@nokia.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/crypto.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/crypto.h b/include/linux/crypto.h
index c0b0cf3..84da997 100644
--- a/include/linux/crypto.h
+++ b/include/linux/crypto.h
@@ -123,7 +123,7 @@
 /*
  * Miscellaneous stuff.
  */
-#define CRYPTO_MAX_ALG_NAME		64
+#define CRYPTO_MAX_ALG_NAME		128
 
 /*
  * The macro CRYPTO_MINALIGN_ATTR (along with the void * type in the actual
