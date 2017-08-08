From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 18/35] wireless: ath: ath9k: constify usb_device_id
Date: Tue,  8 Aug 2017 21:29:32 +0530
Message-ID: <1502207972-11744-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org
To: kvalo@codeaurora.org, petkan@nucleusys.com,
        ath9k-devel@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

usb_device_id are not supposed to change at runtime. All functions
working with usb_device_id provided by <linux/usb.h> work with
const usb_device_id. So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/wireless/ath/ath9k/hif_usb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath9k/hif_usb.c b/drivers/net/wireless/ath/ath9k/hif_usb.c
index 0d9687a..c5f4dd8 100644
--- a/drivers/net/wireless/ath/ath9k/hif_usb.c
+++ b/drivers/net/wireless/ath/ath9k/hif_usb.c
@@ -20,7 +20,7 @@
 MODULE_FIRMWARE(HTC_7010_MODULE_FW);
 MODULE_FIRMWARE(HTC_9271_MODULE_FW);
 
-static struct usb_device_id ath9k_hif_usb_ids[] = {
+static const struct usb_device_id ath9k_hif_usb_ids[] = {
 	{ USB_DEVICE(0x0cf3, 0x9271) }, /* Atheros */
 	{ USB_DEVICE(0x0cf3, 0x1006) }, /* Atheros */
 	{ USB_DEVICE(0x0846, 0x9030) }, /* Netgear N150 */
-- 
2.7.4
