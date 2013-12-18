From: Chen Weilong <chenweilong@huawei.com>
Subject: [patch net-next 1/5] mac80211: fix checkpatch error
Date: Wed, 18 Dec 2013 15:44:12 +0800
Message-ID: <1387352656-860-2-git-send-email-chenweilong@huawei.com>
References: <1387352656-860-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>, <linville@tuxdriver.com>,
	<johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [119.145.14.66] ([119.145.14.66]:14730 "EHLO
	szxga03-in.huawei.com" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751007Ab3LRHpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 02:45:12 -0500
In-Reply-To: <1387352656-860-1-git-send-email-chenweilong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilong Chen <chenweilong@huawei.com>

"foo * bar" should be "foo *bar".

Signed-off-by: Weilong Chen <chenweilong@huawei.com>
---
 net/mac80211/aes_cmac.c | 2 +-
 net/mac80211/aes_cmac.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/mac80211/aes_cmac.c b/net/mac80211/aes_cmac.c
index 537488c..9b9009f 100644
--- a/net/mac80211/aes_cmac.c
+++ b/net/mac80211/aes_cmac.c
@@ -111,7 +111,7 @@ void ieee80211_aes_cmac(struct crypto_cipher *tfm, const u8 *aad,
 }
 
 
-struct crypto_cipher * ieee80211_aes_cmac_key_setup(const u8 key[])
+struct crypto_cipher *ieee80211_aes_cmac_key_setup(const u8 key[])
 {
 	struct crypto_cipher *tfm;
 
diff --git a/net/mac80211/aes_cmac.h b/net/mac80211/aes_cmac.h
index 20785a6..0ce6487 100644
--- a/net/mac80211/aes_cmac.h
+++ b/net/mac80211/aes_cmac.h
@@ -11,7 +11,7 @@
 
 #include <linux/crypto.h>
 
-struct crypto_cipher * ieee80211_aes_cmac_key_setup(const u8 key[]);
+struct crypto_cipher *ieee80211_aes_cmac_key_setup(const u8 key[]);
 void ieee80211_aes_cmac(struct crypto_cipher *tfm, const u8 *aad,
 			const u8 *data, size_t data_len, u8 *mic);
 void ieee80211_aes_cmac_key_free(struct crypto_cipher *tfm);
-- 
1.7.12
