From: freddy@asix.com.tw
Subject: [PATCH 2/2] [PATCH] ax88179_178a: Add VID:DID for Samsung USB Ethernet Adapter
Date: Tue, 22 Oct 2013 15:32:11 +0800
Message-ID: <1382427131-2429-2-git-send-email-freddy@asix.com.tw>
References: <1382427131-2429-1-git-send-email-freddy@asix.com.tw>
Cc: Freddy Xin <freddy@asix.com.tw>
To: davem@davemloft.net, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	allan@asix.com.tw, louis@asix.com.tw
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382427131-2429-1-git-send-email-freddy@asix.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Freddy Xin <freddy@asix.com.tw>

Add VID:DID for Samsung USB Ethernet Adapter.

Signed-off-by: Freddy Xin <freddy@asix.com.tw>
---
 drivers/net/usb/ax88179_178a.c |   19 ++++++++++++++++++-
 1 file changed, 18 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/ax88179_178a.c b/drivers/net/usb/ax88179_178a.c
index 3bcd0d9..846cc19 100644
--- a/drivers/net/usb/ax88179_178a.c
+++ b/drivers/net/usb/ax88179_178a.c
@@ -1406,6 +1406,19 @@ static const struct driver_info sitecom_info = {
 	.tx_fixup = ax88179_tx_fixup,
 };
 
+static const struct driver_info samsung_info = {
+	.description = "Samsung USB Ethernet Adapter",
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
@@ -1418,7 +1431,11 @@ static const struct usb_device_id products[] = {
 }, {
 	/* Sitecom USB 3.0 to Gigabit Adapter */
 	USB_DEVICE(0x0df6, 0x0072),
-	.driver_info = (unsigned long) &sitecom_info,
+	.driver_info = (unsigned long)&sitecom_info,
+}, {
+	/* Samsung USB Ethernet Adapter */
+	USB_DEVICE(0x04e8, 0xa100),
+	.driver_info = (unsigned long)&samsung_info,
 },
 	{ },
 };
-- 
1.7.10.4
