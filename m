From: Masanari Iida <standby24x7-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] [linux-next] rtlwifi: Fix typo in printk
Date: Wed, 29 Jun 2016 12:37:19 +0900
Message-ID: <20160629033719.13215-1-standby24x7@gmail.com>
Cc: Masanari Iida <standby24x7-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, trivial-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	Jes.Sorensen-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch fix spelling typos found in drivers/net/wireless/realtek.

Signed-off-by: Masanari Iida <standby24x7-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/wireless/realtek/rtlwifi/rtl8188ee/phy.c       | 2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8192c/phy_common.c | 2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8192ee/dm.c        | 2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8192ee/phy.c       | 2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8723ae/phy.c       | 2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8723be/hw.c        | 2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8723be/phy.c       | 2 +-
 7 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/phy.c b/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/phy.c
index 416a9ba6382e..422c7813f5ee 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/phy.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/phy.c
@@ -1239,7 +1239,7 @@ u8 rtl88e_phy_sw_chnl(struct ieee80211_hw *hw)
 	if (!(is_hal_stop(rtlhal)) && !(RT_CANNOT_IO(hw))) {
 		rtl88e_phy_sw_chnl_callback(hw);
 		RT_TRACE(rtlpriv, COMP_CHAN, DBG_LOUD,
-			 "sw_chnl_inprogress false schdule workitem current channel %d\n",
+			 "sw_chnl_inprogress false schedule workitem current channel %d\n",
 			 rtlphy->current_channel);
 		rtlphy->sw_chnl_inprogress = false;
 	} else {
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192c/phy_common.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192c/phy_common.c
index 77e61b19bf36..9301583ce768 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192c/phy_common.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192c/phy_common.c
@@ -757,7 +757,7 @@ u8 rtl92c_phy_sw_chnl(struct ieee80211_hw *hw)
 	if (!(is_hal_stop(rtlhal)) && !(RT_CANNOT_IO(hw))) {
 		rtl92c_phy_sw_chnl_callback(hw);
 		RT_TRACE(rtlpriv, COMP_CHAN, DBG_LOUD,
-			 "sw_chnl_inprogress false schdule workitem\n");
+			 "sw_chnl_inprogress false schedule workitem\n");
 		rtlphy->sw_chnl_inprogress = false;
 	} else {
 		RT_TRACE(rtlpriv, COMP_CHAN, DBG_LOUD,
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/dm.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/dm.c
index 459f3d0efa2f..0a5c9fcfe73b 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/dm.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/dm.c
@@ -496,7 +496,7 @@ static void rtl92ee_dm_find_minimum_rssi(struct ieee80211_hw *hw)
 		rtl_dm_dig->min_undec_pwdb_for_dm =
 			rtlpriv->dm.entry_min_undec_sm_pwdb;
 		RT_TRACE(rtlpriv, COMP_BB_POWERSAVING, DBG_LOUD,
-			 "AP Ext Port or disconnet PWDB = 0x%x\n",
+			 "AP Ext Port or disconnect PWDB = 0x%x\n",
 			 rtl_dm_dig->min_undec_pwdb_for_dm);
 	}
 	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/phy.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/phy.c
index c2bf8d1a7af3..97d9a8e209f1 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/phy.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/phy.c
@@ -1819,7 +1819,7 @@ u8 rtl92ee_phy_sw_chnl(struct ieee80211_hw *hw)
 	if (!(is_hal_stop(rtlhal)) && !(RT_CANNOT_IO(hw))) {
 		rtl92ee_phy_sw_chnl_callback(hw);
 		RT_TRACE(rtlpriv, COMP_CHAN, DBG_LOUD,
-			 "sw_chnl_inprogress false schdule workitem current channel %d\n",
+			 "sw_chnl_inprogress false schedule workitem current channel %d\n",
 			 rtlphy->current_channel);
 		rtlphy->sw_chnl_inprogress = false;
 	} else {
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/phy.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/phy.c
index d367097f490b..e9a9bbf44966 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/phy.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/phy.c
@@ -893,7 +893,7 @@ u8 rtl8723e_phy_sw_chnl(struct ieee80211_hw *hw)
 	if (!(is_hal_stop(rtlhal)) && !(RT_CANNOT_IO(hw))) {
 		rtl8723e_phy_sw_chnl_callback(hw);
 		RT_TRACE(rtlpriv, COMP_CHAN, DBG_LOUD,
-			 "sw_chnl_inprogress false schdule workitem\n");
+			 "sw_chnl_inprogress false schedule workitem\n");
 		rtlphy->sw_chnl_inprogress = false;
 	} else {
 		RT_TRACE(rtlpriv, COMP_CHAN, DBG_LOUD,
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/hw.c
index 08288ac9020a..97ae14d48840 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/hw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/hw.c
@@ -1474,7 +1474,7 @@ static enum version_8723e _rtl8723be_read_chip_version(struct ieee80211_hw *hw)
 
 	value32 = rtl_read_dword(rtlpriv, REG_SYS_CFG1);
 	if ((value32 & (CHIP_8723B)) != CHIP_8723B)
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "unkown chip version\n");
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "unknown chip version\n");
 	else
 		version = (enum version_8723e)CHIP_8723B;
 
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/phy.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/phy.c
index c5ca9dfb445c..dbe7c1eb0085 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/phy.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/phy.c
@@ -1395,7 +1395,7 @@ u8 rtl8723be_phy_sw_chnl(struct ieee80211_hw *hw)
 	if (!(is_hal_stop(rtlhal)) && !(RT_CANNOT_IO(hw))) {
 		rtl8723be_phy_sw_chnl_callback(hw);
 		RT_TRACE(rtlpriv, COMP_CHAN, DBG_LOUD,
-			 "sw_chnl_inprogress false schdule workitem current channel %d\n",
+			 "sw_chnl_inprogress false schedule workitem current channel %d\n",
 			 rtlphy->current_channel);
 		rtlphy->sw_chnl_inprogress = false;
 	} else {
-- 
2.9.0.137.gcf4c2cf

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
