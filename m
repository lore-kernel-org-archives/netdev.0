From: Cheolhyun Park <pch851130@gmail.com>
Subject: [PATCH] rtlwifi: misspelled code and comments corrected.
Date: Sun, 12 Apr 2015 16:04:25 +0000
Message-ID: <1428854665-5958-1-git-send-email-pch851130@gmail.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Larry.Finger@lwfinger.net, chaoming_li@realsil.com.cn,
	kvalo@codeaurora.org, pch851130@gmail.com, linville@tuxdriver.com,
	Julia.Lawall@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Cheolhyun Park <pch851130@gmail.com>
---
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c | 2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/dm.c       | 2 +-
 drivers/net/wireless/rtlwifi/rtl8821ae/dm.c       | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c b/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
index f5ee67c..1273997 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
@@ -312,7 +312,7 @@ static void rtl92c_dm_ctrl_initgain_by_rssi(struct ieee80211_hw *hw)
 	struct dig_t *digtable = &rtlpriv->dm_digtable;
 	u32 isbt;
 
-	/* modify DIG lower bound, deal with abnorally large false alarm */
+	/* modify DIG lower bound, deal with abnormally large false alarm */
 	if (rtlpriv->falsealm_cnt.cnt_all > 10000) {
 		digtable->large_fa_hit++;
 		if (digtable->forbidden_igi < digtable->cur_igvalue) {
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/dm.c b/drivers/net/wireless/rtlwifi/rtl8192de/dm.c
index a1be5a6..f209cda 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/dm.c
@@ -420,7 +420,7 @@ static void rtl92d_dm_dig(struct ieee80211_hw *hw)
 		 "dm_DIG() Before: Recover_cnt=%d, rx_gain_min=%x\n",
 		 de_digtable->recover_cnt, de_digtable->rx_gain_min);
 
-	/* deal with abnorally large false alarm */
+	/* deal with abnormally large false alarm */
 	if (falsealm_cnt->cnt_all > 10000) {
 		RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
 			 "dm_DIG(): Abnormally false alarm case\n");
diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/dm.c b/drivers/net/wireless/rtlwifi/rtl8821ae/dm.c
index 0b2082d..342678d 100644
--- a/drivers/net/wireless/rtlwifi/rtl8821ae/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/dm.c
@@ -873,7 +873,7 @@ static void rtl8821ae_dm_dig(struct ieee80211_hw *hw)
 
 	if (rtlpriv->falsealm_cnt.cnt_all > 10000) {
 		RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
-			 "Abnornally false alarm case.\n");
+			 "Abnormally false alarm case.\n");
 
 		if (dm_digtable->large_fa_hit != 3)
 			dm_digtable->large_fa_hit++;
-- 
1.9.1
