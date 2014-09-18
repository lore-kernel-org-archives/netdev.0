From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] [trivial] wireless:rtlwifi: Fix typo in rtl wifi drivers
Date: Thu, 18 Sep 2014 12:29:52 +0900
Message-ID: <1411010992-9999-1-git-send-email-standby24x7@gmail.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Masanari Iida <standby24x7@gmail.com>
To: trivial@kernel.org, linux-kernel@vger.kernel.org,
	Larry.Finger@lwfinger.net, linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fix spelling typo "sleeped" in printk, found in
multiple rtlwifi drivers.

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 drivers/net/wireless/rtlwifi/rtl8188ee/phy.c | 2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/phy.c | 2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/phy.c | 2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/phy.c | 2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/phy.c | 2 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/phy.c | 2 +-
 drivers/net/wireless/rtlwifi/rtl8723be/phy.c | 2 +-
 7 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/phy.c b/drivers/net/wireless/rtlwifi/rtl8188ee/phy.c
index 1cd6c16..3d689e8 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/phy.c
@@ -2019,7 +2019,7 @@ static bool _rtl88ee_phy_set_rf_power_state(struct ieee80211_hw *hw,
 					  RT_RF_OFF_LEVL_HALT_NIC);
 		} else {
 			RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
-				 "Set ERFON sleeped:%d ms\n",
+				 "Set ERFON slept:%d ms\n",
 				 jiffies_to_msecs(jiffies - ppsc->
 						  last_sleep_jiffies));
 			ppsc->last_awake_jiffies = jiffies;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/phy.c b/drivers/net/wireless/rtlwifi/rtl8192ce/phy.c
index 98b2230..ac3ffa2 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/phy.c
@@ -480,7 +480,7 @@ static bool _rtl92ce_phy_set_rf_power_state(struct ieee80211_hw *hw,
 						  RT_RF_OFF_LEVL_HALT_NIC);
 			} else {
 				RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
-					 "Set ERFON sleeped:%d ms\n",
+					 "Set ERFON slept:%d ms\n",
 					 jiffies_to_msecs(jiffies -
 							  ppsc->
 							  last_sleep_jiffies));
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/phy.c b/drivers/net/wireless/rtlwifi/rtl8192cu/phy.c
index 9831ff1..519d6e5 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/phy.c
@@ -437,7 +437,7 @@ static bool _rtl92cu_phy_set_rf_power_state(struct ieee80211_hw *hw,
 					  RT_RF_OFF_LEVL_HALT_NIC);
 		} else {
 			RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
-				 "Set ERFON sleeped:%d ms\n",
+				 "Set ERFON slept:%d ms\n",
 				 jiffies_to_msecs(jiffies -
 						  ppsc->last_sleep_jiffies));
 			ppsc->last_awake_jiffies = jiffies;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/phy.c b/drivers/net/wireless/rtlwifi/rtl8192de/phy.c
index 592125a..7c02247 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/phy.c
@@ -3121,7 +3121,7 @@ bool rtl92d_phy_set_rf_power_state(struct ieee80211_hw *hw,
 					  RT_RF_OFF_LEVL_HALT_NIC);
 		} else {
 			RT_TRACE(rtlpriv, COMP_POWER, DBG_DMESG,
-				 "awake, sleeped:%d ms state_inap:%x\n",
+				 "awake, slept:%d ms state_inap:%x\n",
 				 jiffies_to_msecs(jiffies -
 						  ppsc->last_sleep_jiffies),
 				 rtlpriv->psc.state_inap);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/phy.c b/drivers/net/wireless/rtlwifi/rtl8192se/phy.c
index 77c5b5f..6853ace 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/phy.c
@@ -565,7 +565,7 @@ bool rtl92s_phy_set_rf_power_state(struct ieee80211_hw *hw,
 						  RT_RF_OFF_LEVL_HALT_NIC);
 			} else {
 				RT_TRACE(rtlpriv, COMP_POWER, DBG_DMESG,
-					 "awake, sleeped:%d ms state_inap:%x\n",
+					 "awake, slept:%d ms state_inap:%x\n",
 					 jiffies_to_msecs(jiffies -
 							  ppsc->
 							  last_sleep_jiffies),
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/phy.c b/drivers/net/wireless/rtlwifi/rtl8723ae/phy.c
index 3ea78af..95f9902 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/phy.c
@@ -1486,7 +1486,7 @@ static bool _rtl8723ae_phy_set_rf_power_state(struct ieee80211_hw *hw,
 					  RT_RF_OFF_LEVL_HALT_NIC);
 		} else {
 			RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
-				 "Set ERFON sleeped:%d ms\n",
+				 "Set ERFON slept:%d ms\n",
 				 jiffies_to_msecs(jiffies -
 				 ppsc->last_sleep_jiffies));
 			ppsc->last_awake_jiffies = jiffies;
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/phy.c b/drivers/net/wireless/rtlwifi/rtl8723be/phy.c
index 1575ef9..b49968e 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/phy.c
@@ -2041,7 +2041,7 @@ static bool _rtl8723be_phy_set_rf_power_state(struct ieee80211_hw *hw,
 						  RT_RF_OFF_LEVL_HALT_NIC);
 		} else {
 			RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
-				 "Set ERFON sleeped:%d ms\n",
+				 "Set ERFON slept:%d ms\n",
 				  jiffies_to_msecs(jiffies -
 						   ppsc->last_sleep_jiffies));
 			ppsc->last_awake_jiffies = jiffies;
-- 
2.1.0.238.gce1d3a9
