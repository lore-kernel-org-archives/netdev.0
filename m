From: Luca Ceresoli <luca@lucaceresoli.net>
Subject: [PATCH] net: asix: add support for the Sitecom LN-028 USB adapter
Date: Thu, 26 Feb 2015 00:58:12 +0100
Message-ID: <1424908692-5842-1-git-send-email-luca@lucaceresoli.net>
Cc: Luca Ceresoli <luca@lucaceresoli.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	"David S. Miller" <davem@davemloft.net>, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just another AX88178-based 10/100/1000 USB-to-Ethernet dongle. This one
shows up in lsusb as: "Sitecom Europe B.V. LN-028 Network USB 2.0 Adapter".

Signed-off-by: Luca Ceresoli <luca@lucaceresoli.net>
Cc: Francois Romieu <romieu@fr.zoreil.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: linux-usb@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/usb/Kconfig        | 1 +
 drivers/net/usb/asix_devices.c | 4 ++++
 2 files changed, 5 insertions(+)

diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index 3bd9678..7ba8d08 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -161,6 +161,7 @@ config USB_NET_AX8817X
 	    * Linksys USB200M
 	    * Netgear FA120
 	    * Sitecom LN-029
+	    * Sitecom LN-028
 	    * Intellinet USB 2.0 Ethernet
 	    * ST Lab USB 2.0 Ethernet
 	    * TrendNet TU2-ET100
diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devices.c
index bf49792..1173a24 100644
--- a/drivers/net/usb/asix_devices.c
+++ b/drivers/net/usb/asix_devices.c
@@ -979,6 +979,10 @@ static const struct usb_device_id	products [] = {
 	USB_DEVICE (0x0df6, 0x0056),
 	.driver_info =  (unsigned long) &ax88178_info,
 }, {
+	// Sitecom LN-028 "USB 2.0 10/100/1000 Ethernet adapter"
+	USB_DEVICE (0x0df6, 0x061c),
+	.driver_info =  (unsigned long) &ax88178_info,
+}, {
 	// corega FEther USB2-TX
 	USB_DEVICE (0x07aa, 0x0017),
 	.driver_info =  (unsigned long) &ax8817x_info,
-- 
1.9.1
