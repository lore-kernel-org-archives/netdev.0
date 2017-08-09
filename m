From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH v2 05/20] at76c50x: constify usb_device_id
Date: Wed,  9 Aug 2017 21:55:03 +0530
Message-ID: <1502295903-20986-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org
To: kvalo@codeaurora.org, petkan@nucleusys.com
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

 drivers/net/wireless/atmel/at76c50x-usb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/atmel/at76c50x-usb.c b/drivers/net/wireless/atmel/at76c50x-usb.c
index 09defbc..94bf01f 100644
--- a/drivers/net/wireless/atmel/at76c50x-usb.c
+++ b/drivers/net/wireless/atmel/at76c50x-usb.c
@@ -130,7 +130,7 @@ MODULE_FIRMWARE("atmel_at76c505amx-rfmd.bin");
 
 #define USB_DEVICE_DATA(__ops)	.driver_info = (kernel_ulong_t)(__ops)
 
-static struct usb_device_id dev_table[] = {
+static const struct usb_device_id dev_table[] = {
 	/*
 	 * at76c503-i3861
 	 */
-- 
2.7.4
