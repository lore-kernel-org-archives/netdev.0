From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 2/6] crypto: algif_aead - Include crypto/aead.h
Date: Wed, 22 Apr 2015 15:06:28 +0800
Message-ID: <E1Ykojs-0002CM-Oc@gondolin.me.apana.org.au>
References: <20150422070455.GA8351@gondor.apana.org.au>
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All users of AEAD should include crypto/aead.h instead of
include/linux/crypto.h.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 crypto/algif_aead.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/crypto/algif_aead.c b/crypto/algif_aead.c
index 00a6fe1..53702e9 100644
--- a/crypto/algif_aead.c
+++ b/crypto/algif_aead.c
@@ -13,6 +13,7 @@
  * any later version.
  */
 
+#include <crypto/aead.h>
 #include <crypto/scatterwalk.h>
 #include <crypto/if_alg.h>
 #include <linux/init.h>
