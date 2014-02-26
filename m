From: freddy@asix.com.tw
Subject: [PATCH 1/1] AX88179_178A: Add VID:DID for Lenovo OneLinkDock Gigabit LAN
Date: Wed, 26 Feb 2014 16:54:31 +0800
Message-ID: <1393404871-2248-1-git-send-email-freddy@asix.com.tw>
Cc: davem@davemloft.net, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org, Freddy Xin <freddy@asix.com.tw>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Freddy Xin <freddy@asix.com.tw>

Add VID:DID for Lenovo OneLinkDock Gigabit LAN

Signed-off-by: Freddy Xin <freddy@asix.com.tw>
---
 drivers/net/usb/ax88179_178a.c |   17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/drivers/net/usb/ax88179_178a.c b/drivers/net/usb/ax88179_178a.c
index 955df81..460e823 100644
--- a/drivers/net/usb/ax88179_178a.c
+++ b/drivers/net/usb/ax88179_178a.c
@@ -1421,6 +1421,19 @@ static const struct driver_info samsung_info = {
 	.tx_fixup = ax88179_tx_fixup,
 };
 
+static const struct driver_info lenovo_info = {
+	.description = "Lenovo OneLinkDock Gigabit LAN",
+	.bind = ax88179_bind,
+	.unbind = ax88179_unbind,
+	.status = ax88179_status,
+	.link_reset = ax88179_link_reset,
+	.reset = ax88179_reset,
+	.stop = ax88179_stop,
+	.flags = FLAG_ETHER | FLAG_FRAMING_AX,
+	.rx_fixup = ax88179_rx_fixup,
+	.tx_fixup = ax88179_tx_fixup,
+};
+
 static const struct usb_device_id products[] = {
 {
 	/* ASIX AX88179 10/100/1000 */
@@ -1438,6 +1451,10 @@ static const struct usb_device_id products[] = {
 	/* Samsung USB Ethernet Adapter */
 	USB_DEVICE(0x04e8, 0xa100),
 	.driver_info = (unsigned long)&samsung_info,
+}, {
+	/* Lenovo OneLinkDock Gigabit LAN */
+	USB_DEVICE(0x17ef, 0x304b),
+	.driver_info = (unsigned long)&lenovo_info,
 },
 	{ },
 };
-- 
1.7.10.4
