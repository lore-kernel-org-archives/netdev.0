From: changchias@gmail.com
Subject: [PATCH] net: asix: add support for the Billionton GUSB2AM-1G-B USB adapter
Date: Fri, 16 Oct 2015 02:00:21 +0800
Message-ID: <1444932021-1633-1-git-send-email-changchias@gmail.com>
Cc: Chia-Sheng Chang <changchias@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Luca Ceresoli <luca@lucaceresoli.net>,
	Christoph Jaeger <cj@linux.com>,
	"Woojung.Huh@microchip.com" <Woojung.Huh@microchip.com>,
	Matthew Garrett <mjg59@srcf.ucam.org>,
	Markus Elfring <elfring@users.sourceforge.net>,
	Charles Keepax <ckeepax@opensource.wolfsonmicro.com>,
	netdev@vger.kernel.org
To: linux-usb@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33767 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750939AbbJORxg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 13:53:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chia-Sheng Chang <changchias@gmail.com>

Just another AX88178-based 10/100/1000 USB-to-Ethernet dongle. This one
shows up in lsusb as: "ID 08dd:0114 Billionton Systems, Inc".

Signed-off-by: Chia-Sheng Chang <changchias@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Luca Ceresoli <luca@lucaceresoli.net>
Cc: Christoph Jaeger <cj@linux.com>
Cc: "Woojung.Huh@microchip.com" <Woojung.Huh@microchip.com>
Cc: Matthew Garrett <mjg59@srcf.ucam.org>
Cc: Markus Elfring <elfring@users.sourceforge.net>
Cc: Charles Keepax <ckeepax@opensource.wolfsonmicro.com>
Cc: netdev@vger.kernel.org
Cc: linux-usb@vger.kernel.org
---
 drivers/net/usb/Kconfig        |    1 +
 drivers/net/usb/asix_devices.c |    4 ++++
 2 files changed, 5 insertions(+)

diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index fbb9325..e66805e 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -164,6 +164,7 @@ config USB_NET_AX8817X
 	    * Aten UC210T
 	    * ASIX AX88172
 	    * Billionton Systems, USB2AR
+	    * Billionton Systems, GUSB2AM-1G-B
 	    * Buffalo LUA-U2-KTX
 	    * Corega FEther USB2-TX
 	    * D-Link DUB-E100
diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devices.c
index 1173a24..5cabefc 100644
--- a/drivers/net/usb/asix_devices.c
+++ b/drivers/net/usb/asix_devices.c
@@ -959,6 +959,10 @@ static const struct usb_device_id	products [] = {
 	USB_DEVICE (0x08dd, 0x90ff),
 	.driver_info =  (unsigned long) &ax8817x_info,
 }, {
+	// Billionton Systems, GUSB2AM-1G-B
+	USB_DEVICE(0x08dd, 0x0114),
+	.driver_info =  (unsigned long) &ax88178_info,
+}, {
 	// ATEN UC210T
 	USB_DEVICE (0x0557, 0x2009),
 	.driver_info =  (unsigned long) &ax8817x_info,
-- 
1.7.10.4
