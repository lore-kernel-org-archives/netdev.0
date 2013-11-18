From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 05/12 NEXT] rtlwifi: rtl8192c: Add new definitions in the dm_common header
Date: Mon, 18 Nov 2013 11:11:29 -0600
Message-ID: <1384794696-20314-6-git-send-email-Larry.Finger@lwfinger.net>
References: <1384794696-20314-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>
To: linville@tuxdriver.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1384794696-20314-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Changes in the gain-control mechanism will require some changes in the header.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Stable <stable@vger.kernel.org>
---
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.h | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.h b/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.h
index 518e208..4f232a0 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.h
@@ -91,6 +91,17 @@
 #define TX_POWER_NEAR_FIELD_THRESH_LVL2		74
 #define TX_POWER_NEAR_FIELD_THRESH_LVL1		67
 
+#define DYNAMIC_FUNC_DISABLE			0x0
+#define DYNAMIC_FUNC_DIG			BIT(0)
+#define DYNAMIC_FUNC_HP				BIT(1)
+#define DYNAMIC_FUNC_SS				BIT(2) /*Tx Power Tracking*/
+#define DYNAMIC_FUNC_BT				BIT(3)
+#define DYNAMIC_FUNC_ANT_DIV			BIT(4)
+
+#define	RSSI_CCK				0
+#define	RSSI_OFDM				1
+#define	RSSI_DEFAULT				2
+
 struct swat_t {
 	u8 failure_cnt;
 	u8 try_flag;
@@ -167,5 +178,8 @@ void rtl92c_phy_lc_calibrate(struct ieee80211_hw *hw);
 void rtl92c_phy_iq_calibrate(struct ieee80211_hw *hw, bool recovery);
 void rtl92c_dm_dynamic_txpower(struct ieee80211_hw *hw);
 void rtl92c_dm_bt_coexist(struct ieee80211_hw *hw);
+void dm_savepowerindex(struct ieee80211_hw *hw);
+void dm_writepowerindex(struct ieee80211_hw *hw, u8 value);
+void dm_restorepowerindex(struct ieee80211_hw *hw);
 
 #endif
-- 
1.8.4
