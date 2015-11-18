From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: [PATCH v2 27/27] mac80211_hwsim: move Kconfig entry for sorting alphabetically
Date: Wed, 18 Nov 2015 16:46:06 +0200
Message-ID: <1447857966-19560-28-git-send-email-kvalo@codeaurora.org>
References: <1447857966-19560-1-git-send-email-kvalo@codeaurora.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1447857966-19560-1-git-send-email-kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

mac80211_hwsim was not placed alphabetically correctly in menuconfig, fix that.

Signed-off-by: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
---
 drivers/net/wireless/Kconfig |   26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index 3af6d0b9ca21..8c8edaf1bba6 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -58,6 +58,19 @@ config PCMCIA_WL3501
 	  It has basic support for Linux wireless extensions and initial
 	  micro support for ethtool.
 
+config MAC80211_HWSIM
+	tristate "Simulated radio testing tool for mac80211"
+	depends on MAC80211
+	---help---
+	  This driver is a developer testing tool that can be used to test
+	  IEEE 802.11 networking stack (mac80211) functionality. This is not
+	  needed for normal wireless LAN usage and is only for testing. See
+	  Documentation/networking/mac80211_hwsim for more information on how
+	  to use this tool.
+
+	  To compile this driver as a module, choose M here: the module will be
+	  called mac80211_hwsim.  If unsure, say N.
+
 config USB_NET_RNDIS_WLAN
 	tristate "Wireless RNDIS USB support"
 	depends on USB
@@ -87,17 +100,4 @@ config USB_NET_RNDIS_WLAN
 
 	  If you choose to build a module, it'll be called rndis_wlan.
 
-config MAC80211_HWSIM
-	tristate "Simulated radio testing tool for mac80211"
-	depends on MAC80211
-	---help---
-	  This driver is a developer testing tool that can be used to test
-	  IEEE 802.11 networking stack (mac80211) functionality. This is not
-	  needed for normal wireless LAN usage and is only for testing. See
-	  Documentation/networking/mac80211_hwsim for more information on how
-	  to use this tool.
-
-	  To compile this driver as a module, choose M here: the module will be
-	  called mac80211_hwsim.  If unsure, say N.
