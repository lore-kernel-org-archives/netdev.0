From: Aleksander Morgado <aleksander@aleksander.es>
Subject: [PATCH] cdc_ether: flag the Huawei ME906/ME909 as WWAN
Date: Mon, 23 Oct 2017 17:16:41 +0200
Message-ID: <20171023151641.5674-1-aleksander@aleksander.es>
Cc: linux-kernel@vger.kernel.org,
        Aleksander Morgado <aleksander@aleksander.es>
To: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        oliver@neukum.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Huawei ME906 (12d1:15c1) comes with a standard ECM interface that
requires management via AT commands sent over one of the control TTYs
(e.g. connected with AT^NDISDUP).

Signed-off-by: Aleksander Morgado <aleksander@aleksander.es>
---
 drivers/net/usb/cdc_ether.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 52ea80bcd639..788953afaba3 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -863,6 +863,12 @@ static const struct usb_device_id	products[] = {
 	USB_DEVICE_AND_INTERFACE_INFO(DELL_VENDOR_ID, 0x81ba, USB_CLASS_COMM,
 			USB_CDC_SUBCLASS_ETHERNET, USB_CDC_PROTO_NONE),
 	.driver_info = (kernel_ulong_t)&wwan_info,
+}, {
+	/* Huawei ME906 and ME909 */
+	USB_DEVICE_AND_INTERFACE_INFO(HUAWEI_VENDOR_ID, 0x15c1, USB_CLASS_COMM,
+				      USB_CDC_SUBCLASS_ETHERNET,
+				      USB_CDC_PROTO_NONE),
+	.driver_info = (unsigned long)&wwan_info,
 }, {
 	/* ZTE modules */
 	USB_VENDOR_AND_INTERFACE_INFO(ZTE_VENDOR_ID, USB_CLASS_COMM,
--
2.14.2
