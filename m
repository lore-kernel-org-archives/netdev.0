From: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: [PATCH RESEND] zd1211rw-mac80211: changed Kconfig
Date: Sun, 11 Mar 2007 19:19:31 +0000 (GMT)
Message-ID: <20070311191931.752B67B409F@zog.reactivated.net>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ulrich Kunitz <kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>

Changed the reference to Devicescape stack to mac80211.

Signed-off-by: Ulrich Kunitz <kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>
Signed-off-by: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
---
 drivers/net/wireless/mac80211/zd1211rw/Kconfig |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/mac80211/zd1211rw/Kconfig b/drivers/net/wireless/mac80211/zd1211rw/Kconfig
index f6a5f25..b3c64e0 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/Kconfig
+++ b/drivers/net/wireless/mac80211/zd1211rw/Kconfig
@@ -1,13 +1,13 @@
 config ZD1211RW_MAC80211
-	tristate "ZyDAS ZD1211/ZD1211B USB-wireless support (DeviceScape stack)"
+	tristate "ZyDAS ZD1211/ZD1211B USB support (mac80211 stack)"
 	depends on USB && MAC80211 && WLAN_80211 && EXPERIMENTAL
 	select FW_LOADER
 	---help---
 	  This is an experimental driver for the ZyDAS ZD1211/ZD1211B wireless
 	  chip, present in many USB-wireless adapters.
 
-	  Device firmware is required alongside this driver. You can download the
-	  firmware distribution from http://zd1211.ath.cx/get-firmware
+	  Device firmware is required alongside this driver. You can download
+	  the firmware distribution from http://zd1211.ath.cx/get-firmware
 
 config ZD1211RW_MAC80211_DEBUG
 	bool "ZyDAS ZD1211 debugging"
-- 
1.5.0.3
