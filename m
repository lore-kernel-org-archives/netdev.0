From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 02/35] can: esd_usb2: constify usb_device_id
Date: Tue,  8 Aug 2017 21:25:29 +0530
Message-ID: <1502207730-11404-3-git-send-email-arvind.yadav.cs@gmail.com>
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
 drivers/net/can/usb/esd_usb2.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/usb/esd_usb2.c b/drivers/net/can/usb/esd_usb2.c
index be928ce..00564d7 100644
--- a/drivers/net/can/usb/esd_usb2.c
+++ b/drivers/net/can/usb/esd_usb2.c
@@ -183,7 +183,7 @@ struct __attribute__ ((packed)) esd_usb2_msg {
 	} msg;
 };
 
-static struct usb_device_id esd_usb2_table[] = {
+static const struct usb_device_id esd_usb2_table[] = {
 	{USB_DEVICE(USB_ESDGMBH_VENDOR_ID, USB_CANUSB2_PRODUCT_ID)},
 	{USB_DEVICE(USB_ESDGMBH_VENDOR_ID, USB_CANUSBM_PRODUCT_ID)},
 	{}
-- 
2.7.4
