From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: [PATCH] libertas: fix for wireless Kconfig changes
Date: Sat, 28 Apr 2007 20:28:45 -0400
Message-ID: <20070429002844.GA11225@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Need to change the libertas Kconfig entry to match changes made for
other wireless drivers.

Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
---
diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index c4b3dc2..cb09e6b 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -267,7 +267,7 @@ config IPW2200_DEBUG
 
 config LIBERTAS_USB
 	tristate "Marvell Libertas 8388 802.11a/b/g cards"
-	depends on NET_RADIO && USB
+	depends on USB && WLAN_80211
 	select FW_LOADER
 	---help---
 	  A driver for Marvell Libertas 8388 USB devices.
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
