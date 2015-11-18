From: Kalle Valo <kvalo@codeaurora.org>
Subject: [PATCH v2 22/27] rsi: add vendor Kconfig entry
Date: Wed, 18 Nov 2015 16:46:01 +0200
Message-ID: <1447857966-19560-23-git-send-email-kvalo@codeaurora.org>
References: <1447857966-19560-1-git-send-email-kvalo@codeaurora.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:34927 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933289AbbKROqy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 09:46:54 -0500
In-Reply-To: <1447857966-19560-1-git-send-email-kvalo@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Part of reorganising wireless drivers directory and Kconfig.

Signed-off-by: Kalle Valo <kvalo@codeaurora.org>
---
 drivers/net/wireless/Kconfig     |    2 +-
 drivers/net/wireless/Makefile    |    3 +--
 drivers/net/wireless/rsi/Kconfig |   15 +++++++++++++++
 3 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index 28af8b10a66e..518608403bd3 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -25,6 +25,7 @@ source "drivers/net/wireless/intel/Kconfig"
 source "drivers/net/wireless/intersil/Kconfig"
 source "drivers/net/wireless/marvell/Kconfig"
 source "drivers/net/wireless/realtek/Kconfig"
+source "drivers/net/wireless/rsi/Kconfig"
 source "drivers/net/wireless/st/Kconfig"
 source "drivers/net/wireless/zydas/Kconfig"
 
@@ -99,6 +100,5 @@ source "drivers/net/wireless/ath/Kconfig"
 source "drivers/net/wireless/rt2x00/Kconfig"
 source "drivers/net/wireless/mediatek/Kconfig"
 source "drivers/net/wireless/ti/Kconfig"
-source "drivers/net/wireless/rsi/Kconfig"
 
 endif # WLAN
diff --git a/drivers/net/wireless/Makefile b/drivers/net/wireless/Makefile
index 12f6c59668a5..d38b6cc338df 100644
--- a/drivers/net/wireless/Makefile
+++ b/drivers/net/wireless/Makefile
@@ -10,6 +10,7 @@ obj-$(CONFIG_WLAN_VENDOR_INTEL) += intel/
 obj-$(CONFIG_WLAN_VENDOR_INTERSIL) += intersil/
 obj-$(CONFIG_WLAN_VENDOR_MARVELL) += marvell/
 obj-$(CONFIG_WLAN_VENDOR_REALTEK) += realtek/
+obj-$(CONFIG_WLAN_VENDOR_RSI) += rsi/
 obj-$(CONFIG_WLAN_VENDOR_ST) += st/
 obj-$(CONFIG_WLAN_VENDOR_ZYDAS) += zydas/
 
@@ -28,5 +29,3 @@ obj-$(CONFIG_ATH_CARDS)		+= ath/
 obj-$(CONFIG_MAC80211_HWSIM)	+= mac80211_hwsim.o
 
 obj-$(CONFIG_WL_TI)	+= ti/
-
-obj-$(CONFIG_RSI_91X)	+= rsi/
diff --git a/drivers/net/wireless/rsi/Kconfig b/drivers/net/wireless/rsi/Kconfig
index 35245f994c10..7c5e4ca4e3d0 100644
--- a/drivers/net/wireless/rsi/Kconfig
+++ b/drivers/net/wireless/rsi/Kconfig
@@ -1,3 +1,16 @@
+config WLAN_VENDOR_RSI
+	bool "Redpine Signals Inc devices"
+	default y
+	---help---
+	  If you have a wireless card belonging to this class, say Y.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about  cards. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+if WLAN_VENDOR_RSI
+
 config RSI_91X
 	tristate "Redpine Signals Inc 91x WLAN driver support"
 	depends on MAC80211
@@ -28,3 +41,5 @@ config RSI_USB
 	---help---
 	  This option enables the USB bus support in rsi drivers.
 	  Select M (recommended), if you have a RSI 1x1 wireless module.
+
+endif # WLAN_VENDOR_RSI
-- 
1.7.9.5
