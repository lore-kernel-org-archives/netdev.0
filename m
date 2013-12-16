From: Peter Korsgaard <peter@korsgaard.com>
Subject: [PATCH 3/4] dm9601: make it clear that dm9620/dm9621a are also supported
Date: Mon, 16 Dec 2013 11:35:34 +0100
Message-ID: <1387190135-17052-4-git-send-email-peter@korsgaard.com>
References: <1387190135-17052-1-git-send-email-peter@korsgaard.com>
Cc: joseph_chang@davicom.com.tw, Peter Korsgaard <peter@korsgaard.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f173.google.com ([209.85.215.173]:45754 "EHLO
	mail-ea0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753006Ab3LPKft (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 05:35:49 -0500
Received: by mail-ea0-f173.google.com with SMTP id o10so2135895eaj.4
        for <netdev@vger.kernel.org>; Mon, 16 Dec 2013 02:35:48 -0800 (PST)
In-Reply-To: <1387190135-17052-1-git-send-email-peter@korsgaard.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver nowadays also support dm9620/dm9621a based USB 2.0 ethernet
adapters, so adjust module/driver description and Kconfig help text to
match.

Signed-off-by: Peter Korsgaard <peter@korsgaard.com>
---
 drivers/net/usb/Kconfig  | 6 +++---
 drivers/net/usb/dm9601.c | 6 +++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index 85e4a016..47b0f73 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -276,12 +276,12 @@ config USB_NET_CDC_MBIM
 	  module will be called cdc_mbim.
 
 config USB_NET_DM9601
-	tristate "Davicom DM9601 based USB 1.1 10/100 ethernet devices"
+	tristate "Davicom DM96xx based USB 10/100 ethernet devices"
 	depends on USB_USBNET
 	select CRC32
 	help
-	  This option adds support for Davicom DM9601 based USB 1.1
-	  10/100 Ethernet adapters.
+	  This option adds support for Davicom DM9601/DM9620/DM9621A
+	  based USB 10/100 Ethernet adapters.
 
 config USB_NET_SR9700
 	tristate "CoreChip-sz SR9700 based USB 1.1 10/100 ethernet devices"
diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index aca0285..ca99c35 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -1,5 +1,5 @@
 /*
- * Davicom DM9601 USB 1.1 10/100Mbps ethernet devices
+ * Davicom DM96xx USB 10/100Mbps ethernet devices
  *
  * Peter Korsgaard <jacmet@sunsite.dk>
  *
@@ -548,7 +548,7 @@ static int dm9601_link_reset(struct usbnet *dev)
 }
 
 static const struct driver_info dm9601_info = {
-	.description	= "Davicom DM9601 USB Ethernet",
+	.description	= "Davicom DM96xx USB 10/100 Ethernet",
 	.flags		= FLAG_ETHER | FLAG_LINK_INTR,
 	.bind		= dm9601_bind,
 	.rx_fixup	= dm9601_rx_fixup,
@@ -621,5 +621,5 @@ static struct usb_driver dm9601_driver = {
 module_usb_driver(dm9601_driver);
 
 MODULE_AUTHOR("Peter Korsgaard <jacmet@sunsite.dk>");
-MODULE_DESCRIPTION("Davicom DM9601 USB 1.1 ethernet devices");
+MODULE_DESCRIPTION("Davicom DM96xx USB 10/100 ethernet devices");
 MODULE_LICENSE("GPL");
-- 
1.8.5.1
