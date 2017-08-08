From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 12/35] net: usb: ipheth: constify usb_device_id
Date: Tue,  8 Aug 2017 21:28:03 +0530
Message-ID: <1502207885-11574-3-git-send-email-arvind.yadav.cs@gmail.com>
References: <1502207885-11574-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org
To: kvalo@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502207885-11574-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

usb_device_id are not supposed to change at runtime. All functions
working with usb_device_id provided by <linux/usb.h> work with
const usb_device_id. So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/usb/ipheth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/ipheth.c b/drivers/net/usb/ipheth.c
index 0f213ea..d49c710 100644
--- a/drivers/net/usb/ipheth.c
+++ b/drivers/net/usb/ipheth.c
@@ -87,7 +87,7 @@
 #define IPHETH_CARRIER_CHECK_TIMEOUT round_jiffies_relative(1 * HZ)
 #define IPHETH_CARRIER_ON       0x04
 
-static struct usb_device_id ipheth_table[] = {
+static const struct usb_device_id ipheth_table[] = {
 	{ USB_DEVICE_AND_INTERFACE_INFO(
 		USB_VENDOR_APPLE, USB_PRODUCT_IPHONE,
 		IPHETH_USBINTF_CLASS, IPHETH_USBINTF_SUBCLASS,
-- 
2.7.4
