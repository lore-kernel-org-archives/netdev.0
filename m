From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 01/35] can: ems_usb: constify usb_device_id
Date: Tue,  8 Aug 2017 21:25:28 +0530
Message-ID: <1502207730-11404-2-git-send-email-arvind.yadav.cs@gmail.com>
References: <1502207730-11404-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org
To: kvalo@codeaurora.org, wg@grandegger.com, mkl@pengutronix.de,
        linux-can@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502207730-11404-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

usb_device_id are not supposed to change at runtime. All functions
working with usb_device_id provided by <linux/usb.h> work with
const usb_device_id. So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/can/usb/ems_usb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/usb/ems_usb.c b/drivers/net/can/usb/ems_usb.c
index b3d0275..c78f3a8 100644
--- a/drivers/net/can/usb/ems_usb.c
+++ b/drivers/net/can/usb/ems_usb.c
@@ -222,7 +222,7 @@ struct __packed ems_cpc_msg {
  * Table of devices that work with this driver
  * NOTE: This driver supports only CPC-USB/ARM7 (LPC2119) yet.
  */
-static struct usb_device_id ems_usb_table[] = {
+static const struct usb_device_id ems_usb_table[] = {
 	{USB_DEVICE(USB_CPCUSB_VENDOR_ID, USB_CPCUSB_ARM7_PRODUCT_ID)},
 	{} /* Terminating entry */
 };
-- 
2.7.4
