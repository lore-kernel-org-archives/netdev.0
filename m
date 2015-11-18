From: Kalle Valo <kvalo@codeaurora.org>
Subject: [PATCH v2 24/27] mediatek: unify Kconfig with other vendors
Date: Wed, 18 Nov 2015 16:46:03 +0200
Message-ID: <1447857966-19560-25-git-send-email-kvalo@codeaurora.org>
References: <1447857966-19560-1-git-send-email-kvalo@codeaurora.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447857966-19560-1-git-send-email-kvalo@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Part of reorganising wireless drivers directory and Kconfig.

Signed-off-by: Kalle Valo <kvalo@codeaurora.org>
---
 drivers/net/wireless/Kconfig          |    2 +-
 drivers/net/wireless/Makefile         |    3 +--
 drivers/net/wireless/mediatek/Kconfig |   16 ++++++++++------
 3 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index c58e244b5079..2225e06611fa 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -24,6 +24,7 @@ source "drivers/net/wireless/cisco/Kconfig"
 source "drivers/net/wireless/intel/Kconfig"
 source "drivers/net/wireless/intersil/Kconfig"
 source "drivers/net/wireless/marvell/Kconfig"
+source "drivers/net/wireless/mediatek/Kconfig"
 source "drivers/net/wireless/ralink/Kconfig"
 source "drivers/net/wireless/realtek/Kconfig"
 source "drivers/net/wireless/rsi/Kconfig"
@@ -98,7 +99,6 @@ config MAC80211_HWSIM
 	  called mac80211_hwsim.  If unsure, say N.
 
 source "drivers/net/wireless/ath/Kconfig"
-source "drivers/net/wireless/mediatek/Kconfig"
 source "drivers/net/wireless/ti/Kconfig"
 
 endif # WLAN
diff --git a/drivers/net/wireless/Makefile b/drivers/net/wireless/Makefile
index 8ac72fd44d17..0fa909072846 100644
--- a/drivers/net/wireless/Makefile
+++ b/drivers/net/wireless/Makefile
@@ -9,6 +9,7 @@ obj-$(CONFIG_WLAN_VENDOR_CISCO) += cisco/
 obj-$(CONFIG_WLAN_VENDOR_INTEL) += intel/
 obj-$(CONFIG_WLAN_VENDOR_INTERSIL) += intersil/
 obj-$(CONFIG_WLAN_VENDOR_MARVELL) += marvell/
+obj-$(CONFIG_WLAN_VENDOR_MEDIATEK) += mediatek/
 obj-$(CONFIG_WLAN_VENDOR_RALINK) += ralink/
 obj-$(CONFIG_WLAN_VENDOR_REALTEK) += realtek/
 obj-$(CONFIG_WLAN_VENDOR_RSI) += rsi/
@@ -21,8 +22,6 @@ obj-$(CONFIG_PCMCIA_WL3501)	+= wl3501_cs.o
 
 obj-$(CONFIG_USB_NET_RNDIS_WLAN)	+= rndis_wlan.o
 
-obj-$(CONFIG_WL_MEDIATEK)	+= mediatek/
-
 obj-$(CONFIG_ATH_CARDS)		+= ath/
 
 obj-$(CONFIG_MAC80211_HWSIM)	+= mac80211_hwsim.o
diff --git a/drivers/net/wireless/mediatek/Kconfig b/drivers/net/wireless/mediatek/Kconfig
index cba300c6b5da..28843fed750a 100644
--- a/drivers/net/wireless/mediatek/Kconfig
+++ b/drivers/net/wireless/mediatek/Kconfig
@@ -1,10 +1,14 @@
-menuconfig WL_MEDIATEK
-	bool "Mediatek Wireless LAN support"
+config WLAN_VENDOR_MEDIATEK
+	bool "MediaTek devices"
+	default y
 	---help---
-	  Enable community drivers for MediaTek WiFi devices.
-	  Those drivers make use of the Linux mac80211 stack.
+	  If you have a wireless card belonging to this class, say Y.
 
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about  cards. If you say Y, you will be asked for
+	  your specific card in the following questions.
 
-if WL_MEDIATEK
+if WLAN_VENDOR_MEDIATEK
 source "drivers/net/wireless/mediatek/mt7601u/Kconfig"
-endif # WL_MEDIATEK
+endif # WLAN_VENDOR_MEDIATEK
-- 
1.7.9.5
