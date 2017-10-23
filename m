From: Ran Wang <ran.wang_1-3arQi8VN3Tc@public.gmane.org>
Subject: [PATCH] drivers/net/usb: add device id for TP-LINK UE300 USB 3.0 Ethernet
Date: Mon, 23 Oct 2017 18:10:23 +0800
Message-ID: <20171023101023.5470-1-ran.wang_1@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        hayeswang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Ran Wang <ran.wang_1-3arQi8VN3Tc@public.gmane.org>
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This product is named 'TP-LINK USB 3.0 Gigabit Ethernet Network
Adapter (Model No.is UE300)'. It uses chip RTL8153 and works with
driver drivers/net/usb/r8152.c

Signed-off-by: Ran Wang <ran.wang_1-3arQi8VN3Tc@public.gmane.org>
---
 drivers/net/usb/cdc_ether.c | 8 ++++++++
 drivers/net/usb/r8152.c     | 2 ++
 2 files changed, 10 insertions(+)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 52ea80bcd639..5529bd136624 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -561,6 +561,7 @@ static const struct driver_info wwan_info = {
 #define HP_VENDOR_ID		0x03f0
 #define MICROSOFT_VENDOR_ID	0x045e
 #define UBLOX_VENDOR_ID		0x1546
+#define TPLINK_VENDOR_ID	0x2357
 
 static const struct usb_device_id	products[] = {
 /* BLACKLIST !!
@@ -813,6 +814,13 @@ static const struct usb_device_id	products[] = {
 	.driver_info = 0,
 },
 
+	/* TP-LINK UE300 USB 3.0 Ethernet Adapters (based on Realtek RTL8153) */
+{
+	USB_DEVICE_AND_INTERFACE_INFO(TPLINK_VENDOR_ID, 0x0601, USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_ETHERNET, USB_CDC_PROTO_NONE),
+	.driver_info = 0,
+},
+
 /* WHITELIST!!!
  *
  * CDC Ether uses two interfaces, not necessarily consecutive.
diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 941ece08ba78..d51d9abf7986 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -615,6 +615,7 @@ enum rtl8152_flags {
 #define VENDOR_ID_LENOVO		0x17ef
 #define VENDOR_ID_LINKSYS		0x13b1
 #define VENDOR_ID_NVIDIA		0x0955
+#define VENDOR_ID_TPLINK		0x2357
 
 #define MCU_TYPE_PLA			0x0100
 #define MCU_TYPE_USB			0x0000
@@ -5319,6 +5320,7 @@ static const struct usb_device_id rtl8152_table[] = {
 	{REALTEK_USB_DEVICE(VENDOR_ID_LENOVO,  0x7214)},
 	{REALTEK_USB_DEVICE(VENDOR_ID_LINKSYS, 0x0041)},
 	{REALTEK_USB_DEVICE(VENDOR_ID_NVIDIA,  0x09ff)},
+	{REALTEK_USB_DEVICE(VENDOR_ID_TPLINK,  0x0601)},
 	{}
 };
 
-- 
2.14.1

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
