From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 24/35] wireless: marvell: libertas: constify usb_device_id
Date: Tue,  8 Aug 2017 21:32:50 +0530
Message-ID: <1502208171-12118-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org
To: kvalo@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

usb_device_id are not supposed to change at runtime. All functions
working with usb_device_id provided by <linux/usb.h> work with
const usb_device_id. So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/wireless/marvell/libertas/if_usb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/marvell/libertas/if_usb.c b/drivers/net/wireless/marvell/libertas/if_usb.c
index e53025e..16e54c7 100644
--- a/drivers/net/wireless/marvell/libertas/if_usb.c
+++ b/drivers/net/wireless/marvell/libertas/if_usb.c
@@ -52,7 +52,7 @@ static const struct lbs_fw_table fw_table[] = {
 	{ MODEL_8682, "libertas/usb8682.bin", NULL }
 };
 
-static struct usb_device_id if_usb_table[] = {
+static const struct usb_device_id if_usb_table[] = {
 	/* Enter the device signature inside */
 	{ USB_DEVICE(0x1286, 0x2001), .driver_info = MODEL_8388 },
 	{ USB_DEVICE(0x05a3, 0x8388), .driver_info = MODEL_8388 },
-- 
2.7.4
