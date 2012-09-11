From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] rtlwifi: Remove EXPERIMENTAL as pre-requisite for the drivers
Date: Tue, 11 Sep 2012 16:04:36 -0500
Message-ID: <1347397476-13282-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f51.google.com ([209.85.213.51]:50838 "EHLO
	mail-yw0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755561Ab2IKVFE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2012 17:05:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All of the rtlwifi-family of drivers have been in the kernel since 3.1
or earlier. The dependence on EXPERIMENTAL can be removed.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---

John,

There is no rush on this patch. Inclusion in 3.7 will be fine.

Larry
---

 drivers/net/wireless/rtlwifi/Kconfig |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/Kconfig b/drivers/net/wireless/rtlwifi/Kconfig
index cefac6a..6b28e92 100644
--- a/drivers/net/wireless/rtlwifi/Kconfig
+++ b/drivers/net/wireless/rtlwifi/Kconfig
@@ -1,6 +1,6 @@
 config RTL8192CE
 	tristate "Realtek RTL8192CE/RTL8188CE Wireless Network Adapter"
-	depends on MAC80211 && PCI && EXPERIMENTAL
+	depends on MAC80211 && PCI
 	select FW_LOADER
 	select RTLWIFI
 	select RTL8192C_COMMON
@@ -12,7 +12,7 @@ config RTL8192CE
 
 config RTL8192SE
 	tristate "Realtek RTL8192SE/RTL8191SE PCIe Wireless Network Adapter"
-	depends on MAC80211 && EXPERIMENTAL && PCI
+	depends on MAC80211 && PCI
 	select FW_LOADER
 	select RTLWIFI
 	---help---
@@ -23,7 +23,7 @@ config RTL8192SE
 
 config RTL8192DE
 	tristate "Realtek RTL8192DE/RTL8188DE PCIe Wireless Network Adapter"
-	depends on MAC80211 && EXPERIMENTAL && PCI
+	depends on MAC80211 && PCI
 	select FW_LOADER
 	select RTLWIFI
 	---help---
@@ -34,7 +34,7 @@ config RTL8192DE
 
 config RTL8192CU
 	tristate "Realtek RTL8192CU/RTL8188CU USB Wireless Network Adapter"
-	depends on MAC80211 && USB && EXPERIMENTAL
+	depends on MAC80211 && USB
 	select FW_LOADER
 	select RTLWIFI
 	select RTL8192C_COMMON
-- 
1.7.10.4
