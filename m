From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/6] crypto: arm64/aes-ce-ccm - Include crypto/internal/aead.h
Date: Wed, 22 Apr 2015 15:06:27 +0800
Message-ID: <E1Ykojr-0002C3-Fr@gondolin.me.apana.org.au>
References: <20150422070455.GA8351@gondor.apana.org.au>
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All implementers of AEAD should include crypto/internal/aead.h
instead of include/linux/crypto.h.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 arch/arm64/crypto/aes-ce-ccm-glue.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/arm64/crypto/aes-ce-ccm-glue.c b/arch/arm64/crypto/aes-ce-ccm-glue.c
index 6c348df..3303e8a 100644
--- a/arch/arm64/crypto/aes-ce-ccm-glue.c
+++ b/arch/arm64/crypto/aes-ce-ccm-glue.c
@@ -13,7 +13,7 @@
 #include <crypto/aes.h>
 #include <crypto/algapi.h>
 #include <crypto/scatterwalk.h>
-#include <linux/crypto.h>
+#include <crypto/internal/aead.h>
 #include <linux/module.h>
 
 #include "aes-ce-setkey.h"
