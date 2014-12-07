From: Julia Lawall <Julia.Lawall-L2FTfq7BK8M@public.gmane.org>
Subject: [PATCH 16/20] rtlwifi: rtl8821ae: fix misspelling of current function in string
Date: Sun,  7 Dec 2014 20:20:58 +0100
Message-ID: <1417980062-25151-17-git-send-email-Julia.Lawall@lip6.fr>
References: <1417980062-25151-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-qQsb+v5E8BnlAoU/VqSP6n9LOBIZ5rWg@public.gmane.org,
	joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org, Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1417980062-25151-1-git-send-email-Julia.Lawall-L2FTfq7BK8M@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Replace a misspelled function name by %s and then __func__.

8821 was written as 8812.

This was done using Coccinelle, including the use of Levenshtein distance,
as proposed by Rasmus Villemoes.

Signed-off-by: Julia Lawall <Julia.Lawall-L2FTfq7BK8M@public.gmane.org>

---
The semantic patch is difficult to summarize, but is available in the cover
letter of this patch series.

 drivers/net/wireless/rtlwifi/rtl8821ae/dm.c |   11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/dm.c b/drivers/net/wireless/rtlwifi/rtl8821ae/dm.c
index 9be1061..ba30b0d 100644
--- a/drivers/net/wireless/rtlwifi/rtl8821ae/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/dm.c
@@ -2078,8 +2078,7 @@ void rtl8821ae_dm_txpwr_track_set_pwr(struct ieee80211_hw *hw,
 	if (rtldm->tx_rate != 0xFF)
 		tx_rate = rtl8821ae_hw_rate_to_mrate(hw, rtldm->tx_rate);
 
-	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
-		 "===>rtl8812ae_dm_txpwr_track_set_pwr\n");
+	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD, "===>%s\n", __func__);
 
 	if (tx_rate != 0xFF) { /* Mimic Modify High Rate BBSwing Limit.*/
 		/*CCK*/
@@ -2128,7 +2127,7 @@ void rtl8821ae_dm_txpwr_track_set_pwr(struct ieee80211_hw *hw,
 
 	if (method == BBSWING) {
 		RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
-			 "===>rtl8812ae_dm_txpwr_track_set_pwr\n");
+			 "===>%s\n", __func__);
 		if (rf_path == RF90_PATH_A) {
 			final_swing_idx[RF90_PATH_A] =
 				(rtldm->ofdm_index[RF90_PATH_A] >
@@ -2260,7 +2259,8 @@ void rtl8821ae_dm_txpower_tracking_callback_thermalmeter(
 	rtldm->txpower_trackinginit = true;
 
 	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
-		 "===>rtl8812ae_dm_txpower_tracking_callback_thermalmeter,\n pDM_Odm->BbSwingIdxCckBase: %d,pDM_Odm->BbSwingIdxOfdmBase[A]:%d, pDM_Odm->DefaultOfdmIndex: %d\n",
+		 "===>%s,\n pDM_Odm->BbSwingIdxCckBase: %d,pDM_Odm->BbSwingIdxOfdmBase[A]:%d, pDM_Odm->DefaultOfdmIndex: %d\n",
+		 __func__,
 		 rtldm->swing_idx_cck_base,
 		 rtldm->swing_idx_ofdm_base[RF90_PATH_A],
 		 rtldm->default_ofdm_index);
@@ -2539,8 +2539,7 @@ void rtl8821ae_dm_txpower_tracking_callback_thermalmeter(
 		}
 	}
 
-	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
-		 "<===rtl8812ae_dm_txpower_tracking_callback_thermalmeter\n");
+	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD, "<===%s\n", __func__);
 }
 
 void rtl8821ae_dm_check_txpower_tracking_thermalmeter(struct ieee80211_hw *hw)
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
