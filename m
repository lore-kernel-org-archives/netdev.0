From: Priit Laes <plaes@plaes.org>
Subject: [PATCH 3/7] rtlwifi: Remove unused RF6052_MAX_REG define
Date: Tue, 27 Jan 2015 08:49:29 +0200
Message-ID: <1422341373-22196-3-git-send-email-plaes@plaes.org>
References: <1422341373-22196-1-git-send-email-plaes@plaes.org>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Priit Laes <plaes@plaes.org>
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422341373-22196-1-git-send-email-plaes@plaes.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Priit Laes <plaes@plaes.org>
---
 drivers/net/wireless/rtlwifi/rtl8188ee/rf.h  | 1 -
 drivers/net/wireless/rtlwifi/rtl8192ce/rf.h  | 1 -
 drivers/net/wireless/rtlwifi/rtl8192cu/rf.h  | 1 -
 drivers/net/wireless/rtlwifi/rtl8192de/def.h | 1 -
 drivers/net/wireless/rtlwifi/rtl8192ee/rf.h  | 1 -
 drivers/net/wireless/rtlwifi/rtl8723ae/rf.h  | 1 -
 drivers/net/wireless/rtlwifi/rtl8723be/rf.h  | 1 -
 drivers/net/wireless/rtlwifi/rtl8821ae/rf.h  | 1 -
 8 files changed, 8 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/rf.h b/drivers/net/wireless/rtlwifi/rtl8188ee/rf.h
index 5c1472d..0eca030 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/rf.h
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/rf.h
@@ -27,7 +27,6 @@
 #define __RTL92C_RF_H__
 
 #define RF6052_MAX_TX_PWR		0x3F
-#define RF6052_MAX_REG			0x3F
 
 void rtl88e_phy_rf6052_set_bandwidth(struct ieee80211_hw *hw,
 				     u8 bandwidth);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/rf.h b/drivers/net/wireless/rtlwifi/rtl8192ce/rf.h
index d8fe68b..ebd72ca 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/rf.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/rf.h
@@ -31,7 +31,6 @@
 #define __RTL92C_RF_H__
 
 #define RF6052_MAX_TX_PWR		0x3F
-#define RF6052_MAX_REG			0x3F
 #define RF6052_MAX_PATH			2
 
 void rtl92ce_phy_rf6052_set_bandwidth(struct ieee80211_hw *hw, u8 bandwidth);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/rf.h b/drivers/net/wireless/rtlwifi/rtl8192cu/rf.h
index 11b439d..6f987de 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/rf.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/rf.h
@@ -31,7 +31,6 @@
 #define __RTL92CU_RF_H__
 
 #define RF6052_MAX_TX_PWR		0x3F
-#define RF6052_MAX_REG			0x3F
 #define RF6052_MAX_PATH			2
 
 void rtl92cu_phy_rf6052_set_bandwidth(struct ieee80211_hw *hw, u8 bandwidth);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/def.h b/drivers/net/wireless/rtlwifi/rtl8192de/def.h
index 4ca1fe1..0a443ed 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/def.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/def.h
@@ -35,7 +35,6 @@
 #define	MAX_MSS_DENSITY_1T				0x0A
 
 #define RF6052_MAX_TX_PWR				0x3F
-#define RF6052_MAX_REG					0x3F
 #define RF6052_MAX_PATH					2
 
 #define	PHY_RSSI_SLID_WIN_MAX				100
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ee/rf.h b/drivers/net/wireless/rtlwifi/rtl8192ee/rf.h
index 8bdeed3..039c013 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ee/rf.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192ee/rf.h
@@ -27,7 +27,6 @@
 #define __RTL92E_RF_H__
 
 #define RF6052_MAX_TX_PWR		0x3F
-#define RF6052_MAX_REG			0x3F
 
 void rtl92ee_phy_rf6052_set_bandwidth(struct ieee80211_hw *hw,
 				      u8 bandwidth);
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/rf.h b/drivers/net/wireless/rtlwifi/rtl8723ae/rf.h
index f3f45b1..7b44ebc 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/rf.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/rf.h
@@ -27,7 +27,6 @@
 #define __RTL8723E_RF_H__
 
 #define RF6052_MAX_TX_PWR		0x3F
-#define RF6052_MAX_REG			0x3F
 
 void rtl8723e_phy_rf6052_set_bandwidth(struct ieee80211_hw *hw,
 				       u8 bandwidth);
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/rf.h b/drivers/net/wireless/rtlwifi/rtl8723be/rf.h
index a6fea10..f423e15 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/rf.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/rf.h
@@ -27,7 +27,6 @@
 #define __RTL8723BE_RF_H__
 
 #define RF6052_MAX_TX_PWR		0x3F
-#define RF6052_MAX_REG			0x3F
 
 void rtl8723be_phy_rf6052_set_bandwidth(struct ieee80211_hw *hw,
 					u8 bandwidth);
diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/rf.h b/drivers/net/wireless/rtlwifi/rtl8821ae/rf.h
index d9582ee..efd22bd 100644
--- a/drivers/net/wireless/rtlwifi/rtl8821ae/rf.h
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/rf.h
@@ -27,7 +27,6 @@
 #define __RTL8821AE_RF_H__
 
 #define RF6052_MAX_TX_PWR		0x3F
-#define RF6052_MAX_REG			0x3F
 
 void rtl8821ae_phy_rf6052_set_bandwidth(struct ieee80211_hw *hw,
 					u8 bandwidth);
-- 
2.2.2
