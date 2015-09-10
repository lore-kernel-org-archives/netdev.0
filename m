From: <Woojung.Huh@microchip.com>
Subject: [PATCH 2/5] lan78xx: Add PHYLIB and MICROCHIP_PHY as default config.
Date: Thu, 10 Sep 2015 22:16:08 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D557D98@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>, <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp02.microchip.com ([198.175.253.38]:39688 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751130AbbIJWQI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 18:16:08 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add PHYLIB and MICROCHIP_PHY as default configuration for  lan78xx.

Repost with new order of patches.

Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
---
 drivers/net/usb/Kconfig | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index 1610b79..d9ca7aa 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -109,6 +109,8 @@ config USB_RTL8152
 config USB_LAN78XX
 	tristate "Microchip LAN78XX Based USB Ethernet Adapters"
 	select MII
+	select PHYLIB
+	select MICROCHIP_PHY
 	help
 	  This option adds support for Microchip LAN78XX based USB 2
 	  & USB 3 10/100/1000 Ethernet adapters.
-- 
2.1.4
