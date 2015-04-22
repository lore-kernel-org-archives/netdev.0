From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 6/6] mac802154: Include crypto/aead.h
Date: Wed, 22 Apr 2015 15:06:33 +0800
Message-ID: <E1Ykojx-0002DS-Ht@gondolin.me.apana.org.au>
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

This patch also removes a bogus inclusion of algapi.h which should
only be used by algorithm/driver implementors and not crypto users.

Instead linux/crypto.h is added which is necessary because mac802154
also uses blkcipher in addition to aead.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/mac802154/llsec.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/mac802154/llsec.c b/net/mac802154/llsec.c
index dcf7395..3ccf1e9 100644
--- a/net/mac802154/llsec.c
+++ b/net/mac802154/llsec.c
@@ -17,8 +17,9 @@
 #include <linux/err.h>
 #include <linux/bug.h>
 #include <linux/completion.h>
+#include <linux/crypto.h>
 #include <linux/ieee802154.h>
-#include <crypto/algapi.h>
+#include <crypto/aead.h>
 
 #include "ieee802154_i.h"
 #include "llsec.h"
