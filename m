From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next] r8152: add new products of Lenovo
Date: Tue, 18 Oct 2016 11:41:48 +0800
Message-ID: <1394712342-15778-225-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>, <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([211.75.126.72]:49778 "EHLO
        rtits2.realtek.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753763AbcJRDol (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 23:44:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the following four products of Lenovo and sort the order of the list.

	VID		PID
	0x17ef		0x3062
	0x17ef		0x3069
	0x17ef		0x720c
	0x17ef		0x7214

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/cdc_ether.c | 28 ++++++++++++++++++++++++++++
 drivers/net/usb/r8152.c     |  6 +++++-
 2 files changed, 33 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index c47ec0a..45e5e43 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -687,6 +687,20 @@ static const struct usb_device_id	products[] = {
 	.driver_info = 0,
 },
 
+/* ThinkPad USB-C Dock (based on Realtek RTL8153) */
+{
+	USB_DEVICE_AND_INTERFACE_INFO(LENOVO_VENDOR_ID, 0x3062, USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_ETHERNET, USB_CDC_PROTO_NONE),
+	.driver_info = 0,
+},
+
+/* ThinkPad Thunderbolt 3 Dock (based on Realtek RTL8153) */
+{
+	USB_DEVICE_AND_INTERFACE_INFO(LENOVO_VENDOR_ID, 0x3069, USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_ETHERNET, USB_CDC_PROTO_NONE),
+	.driver_info = 0,
+},
+
 /* Lenovo Thinkpad USB 3.0 Ethernet Adapters (based on Realtek RTL8153) */
 {
 	USB_DEVICE_AND_INTERFACE_INFO(LENOVO_VENDOR_ID, 0x7205, USB_CLASS_COMM,
@@ -694,6 +708,20 @@ static const struct usb_device_id	products[] = {
 	.driver_info = 0,
 },
 
+/* Lenovo USB C to Ethernet Adapter (based on Realtek RTL8153) */
+{
+	USB_DEVICE_AND_INTERFACE_INFO(LENOVO_VENDOR_ID, 0x720c, USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_ETHERNET, USB_CDC_PROTO_NONE),
+	.driver_info = 0,
+},
+
+/* Lenovo USB-C Travel Hub (based on Realtek RTL8153) */
+{
+	USB_DEVICE_AND_INTERFACE_INFO(LENOVO_VENDOR_ID, 0x7214, USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_ETHERNET, USB_CDC_PROTO_NONE),
+	.driver_info = 0,
+},
+
 /* NVIDIA Tegra USB 3.0 Ethernet Adapters (based on Realtek RTL8153) */
 {
 	USB_DEVICE_AND_INTERFACE_INFO(NVIDIA_VENDOR_ID, 0x09ff, USB_CLASS_COMM,
diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 2886946..8d6e13c 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -4411,8 +4411,12 @@ static struct usb_device_id rtl8152_table[] = {
 	{REALTEK_USB_DEVICE(VENDOR_ID_REALTEK, 0x8152)},
 	{REALTEK_USB_DEVICE(VENDOR_ID_REALTEK, 0x8153)},
 	{REALTEK_USB_DEVICE(VENDOR_ID_SAMSUNG, 0xa101)},
-	{REALTEK_USB_DEVICE(VENDOR_ID_LENOVO,  0x7205)},
 	{REALTEK_USB_DEVICE(VENDOR_ID_LENOVO,  0x304f)},
+	{REALTEK_USB_DEVICE(VENDOR_ID_LENOVO,  0x3062)},
+	{REALTEK_USB_DEVICE(VENDOR_ID_LENOVO,  0x3069)},
+	{REALTEK_USB_DEVICE(VENDOR_ID_LENOVO,  0x7205)},
+	{REALTEK_USB_DEVICE(VENDOR_ID_LENOVO,  0x720c)},
+	{REALTEK_USB_DEVICE(VENDOR_ID_LENOVO,  0x7214)},
 	{REALTEK_USB_DEVICE(VENDOR_ID_NVIDIA,  0x09ff)},
 	{}
 };
-- 
2.7.4
