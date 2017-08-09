From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH v2 04/20] carl9170: constify usb_device_id
Date: Wed,  9 Aug 2017 21:54:41 +0530
Message-ID: <1502295881-20936-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org
To: kvalo@codeaurora.org, petkan@nucleusys.com, chunkeey@googlemail.com
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

 drivers/net/wireless/ath/carl9170/usb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/carl9170/usb.c b/drivers/net/wireless/ath/carl9170/usb.c
index 99ab203..e7c3f3b 100644
--- a/drivers/net/wireless/ath/carl9170/usb.c
+++ b/drivers/net/wireless/ath/carl9170/usb.c
@@ -64,7 +64,7 @@ MODULE_ALIAS("arusb_lnx");
  * http://wireless.kernel.org/en/users/Drivers/ar9170/devices ),
  * whenever you add a new device.
  */
-static struct usb_device_id carl9170_usb_ids[] = {
+static const struct usb_device_id carl9170_usb_ids[] = {
 	/* Atheros 9170 */
 	{ USB_DEVICE(0x0cf3, 0x9170) },
 	/* Atheros TG121N */
-- 
2.7.4
