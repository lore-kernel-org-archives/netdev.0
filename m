From: <Woojung.Huh@microchip.com>
Subject: [PATCH net 2/6] lan78xx: Add PHYLIB and MICROCHIP_PHY as default
 config.
Date: Wed, 16 Sep 2015 23:40:47 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D55C68F@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp01.microchip.com ([198.175.253.37]:47297 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752663AbbIPXks convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2015 19:40:48 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add PHYLIB and MICROCHIP_PHY as default configuration for lan78xx.

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
