From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH v2 08/20] p54: constify usb_device_id
Date: Wed,  9 Aug 2017 21:56:43 +0530
Message-ID: <1502296003-21197-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org
To: kvalo@codeaurora.org, chunkeey@googlemail.com
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

 drivers/net/wireless/intersil/p54/p54usb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/intersil/p54/p54usb.c b/drivers/net/wireless/intersil/p54/p54usb.c
index 043bd1c..b0b86f7 100644
--- a/drivers/net/wireless/intersil/p54/p54usb.c
+++ b/drivers/net/wireless/intersil/p54/p54usb.c
@@ -41,7 +41,7 @@ MODULE_FIRMWARE("isl3887usb");
  * whenever you add a new device.
  */
 
-static struct usb_device_id p54u_table[] = {
+static const struct usb_device_id p54u_table[] = {
 	/* Version 1 devices (pci chip + net2280) */
 	{USB_DEVICE(0x0411, 0x0050)},	/* Buffalo WLI2-USB2-G54 */
 	{USB_DEVICE(0x045e, 0x00c2)},	/* Microsoft MN-710 */
-- 
2.7.4
