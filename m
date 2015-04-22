From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 5/6] mac80211: Include crypto/aead.h
Date: Wed, 22 Apr 2015 15:06:32 +0800
Message-ID: <E1Ykojw-0002DB-BM@gondolin.me.apana.org.au>
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

 net/mac80211/aes_ccm.c  |    3 +--
 net/mac80211/aes_gcm.c  |    3 +--
 net/mac80211/aes_gmac.c |    2 +-
 3 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/mac80211/aes_ccm.c b/net/mac80211/aes_ccm.c
index 208df7c..70d53da 100644
--- a/net/mac80211/aes_ccm.c
+++ b/net/mac80211/aes_ccm.c
@@ -11,9 +11,8 @@
 
 #include <linux/kernel.h>
 #include <linux/types.h>
-#include <linux/crypto.h>
 #include <linux/err.h>
-#include <crypto/aes.h>
+#include <crypto/aead.h>
 
 #include <net/mac80211.h>
 #include "key.h"
diff --git a/net/mac80211/aes_gcm.c b/net/mac80211/aes_gcm.c
index fd278bb..b91c9d7 100644
--- a/net/mac80211/aes_gcm.c
+++ b/net/mac80211/aes_gcm.c
@@ -8,9 +8,8 @@
 
 #include <linux/kernel.h>
 #include <linux/types.h>
-#include <linux/crypto.h>
 #include <linux/err.h>
-#include <crypto/aes.h>
+#include <crypto/aead.h>
 
 #include <net/mac80211.h>
 #include "key.h"
diff --git a/net/mac80211/aes_gmac.c b/net/mac80211/aes_gmac.c
index f1321b7..c34b06ca 100644
--- a/net/mac80211/aes_gmac.c
+++ b/net/mac80211/aes_gmac.c
@@ -9,8 +9,8 @@
 
 #include <linux/kernel.h>
 #include <linux/types.h>
-#include <linux/crypto.h>
 #include <linux/err.h>
+#include <crypto/aead.h>
 #include <crypto/aes.h>
 
 #include <net/mac80211.h>
