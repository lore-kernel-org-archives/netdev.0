From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 3/6] crypto: tcrypt - Include crypto/aead.h
Date: Wed, 22 Apr 2015 15:06:30 +0800
Message-ID: <E1Ykoju-0002Cd-0W@gondolin.me.apana.org.au>
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

 crypto/tcrypt.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/crypto/tcrypt.c b/crypto/tcrypt.c
index 22cdd61..2bff613 100644
--- a/crypto/tcrypt.c
+++ b/crypto/tcrypt.c
@@ -22,6 +22,7 @@
  *
  */
 
+#include <crypto/aead.h>
 #include <crypto/hash.h>
 #include <linux/err.h>
 #include <linux/fips.h>
