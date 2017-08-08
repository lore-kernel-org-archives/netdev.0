From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 16/35] wireless: ath: ar5523: constify usb_device_id
Date: Tue,  8 Aug 2017 21:29:10 +0530
Message-ID: <1502207951-11692-1-git-send-email-arvind.yadav.cs@gmail.com>
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
 drivers/net/wireless/ath/ar5523/ar5523.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ar5523/ar5523.c b/drivers/net/wireless/ath/ar5523/ar5523.c
index 106d6f8..68f0463 100644
--- a/drivers/net/wireless/ath/ar5523/ar5523.c
+++ b/drivers/net/wireless/ath/ar5523/ar5523.c
@@ -1749,7 +1749,7 @@ static void ar5523_disconnect(struct usb_interface *intf)
 	{ USB_DEVICE((vendor), (device) + 1), \
 		.driver_info = AR5523_FLAG_ABG|AR5523_FLAG_PRE_FIRMWARE }
 
-static struct usb_device_id ar5523_id_table[] = {
+static const struct usb_device_id ar5523_id_table[] = {
 	AR5523_DEVICE_UG(0x168c, 0x0001),	/* Atheros / AR5523 */
 	AR5523_DEVICE_UG(0x0cf3, 0x0001),	/* Atheros2 / AR5523_1 */
 	AR5523_DEVICE_UG(0x0cf3, 0x0003),	/* Atheros2 / AR5523_2 */
-- 
2.7.4
