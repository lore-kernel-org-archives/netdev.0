From: Colin King <colin.king@canonical.com>
Subject: [PATCH] rtlwifi: fix spelling mistake: "Pairwiase" -> "Pairwise"
Date: Wed,  3 May 2017 23:55:43 +0100
Message-ID: <20170503225543.10296-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
        Chaoming Li <chaoming_li@realsil.com.cn>,
        Kalle Valo <kvalo@codeaurora.org>,
        Joe Perches <joe@perches.com>,
        Ping-Ke Shih <pkshih@realtek.com>,
        linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:46472 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751561AbdECWzx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 18:55:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

trivial fixes to spelling mistakes in RT_TRACE messages.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/wireless/realtek/rtlwifi/rtl8192ee/hw.c | 2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hw.c | 2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8723be/hw.c | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/hw.c
index 6f5098a18655..11d97fa0e921 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/hw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/hw.c
@@ -2506,7 +2506,7 @@ void rtl92ee_set_key(struct ieee80211_hw *hw, u32 key_index,
 				 "add one entry\n");
 			if (is_pairwise) {
 				RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
-					 "set Pairwiase key\n");
+					 "set Pairwise key\n");
 
 				rtl_cam_add_one_entry(hw, macaddr, key_index,
 					       entry_id, enc_algo,
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hw.c
index 859c045bd37c..513c27be3868 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hw.c
@@ -2264,7 +2264,7 @@ void rtl8723e_set_key(struct ieee80211_hw *hw, u32 key_index,
 				 "add one entry\n");
 			if (is_pairwise) {
 				RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
-					 "set Pairwiase key\n");
+					 "set Pairwise key\n");
 
 				rtl_cam_add_one_entry(hw, macaddr, key_index,
 						      entry_id, enc_algo,
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/hw.c
index 1acbfb86472c..a79f936bb394 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/hw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/hw.c
@@ -2637,7 +2637,7 @@ void rtl8723be_set_key(struct ieee80211_hw *hw, u32 key_index,
 				 "add one entry\n");
 			if (is_pairwise) {
 				RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
-					 "set Pairwiase key\n");
+					 "set Pairwise key\n");
 
 				rtl_cam_add_one_entry(hw, macaddr, key_index,
 					       entry_id, enc_algo,
-- 
2.11.0
