From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH v2 07/20] orinoco: constify usb_device_id
Date: Wed,  9 Aug 2017 21:56:28 +0530
Message-ID: <1502295988-21144-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org
To: kvalo@codeaurora.org, elena.reshetova@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

usb_device_id are not supposed to change at runtime. All functions
working with usb_device_id provided by <linux/usb.h> work with
const usb_device_id. So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
changes in v2:
              Re-submitting wireless separately.

 drivers/net/wireless/intersil/orinoco/orinoco_usb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/intersil/orinoco/orinoco_usb.c b/drivers/net/wireless/intersil/orinoco/orinoco_usb.c
index c84fd84..56f6e3b 100644
--- a/drivers/net/wireless/intersil/orinoco/orinoco_usb.c
+++ b/drivers/net/wireless/intersil/orinoco/orinoco_usb.c
@@ -210,7 +210,7 @@ struct ezusb_packet {
 } __packed;
 
 /* Table of devices that work or may work with this driver */
-static struct usb_device_id ezusb_table[] = {
+static const struct usb_device_id ezusb_table[] = {
 	{USB_DEVICE(USB_COMPAQ_VENDOR_ID, USB_COMPAQ_WL215_ID)},
 	{USB_DEVICE(USB_COMPAQ_VENDOR_ID, USB_HP_WL215_ID)},
 	{USB_DEVICE(USB_COMPAQ_VENDOR_ID, USB_COMPAQ_W200_ID)},
-- 
2.7.4
