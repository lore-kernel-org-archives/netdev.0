From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH v2 02/20] ath6kl: constify usb_device_id
Date: Wed,  9 Aug 2017 21:53:43 +0530
Message-ID: <1502295823-20824-3-git-send-email-arvind.yadav.cs@gmail.com>
References: <1502295823-20824-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org
To: kvalo@codeaurora.org, petkan@nucleusys.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502295823-20824-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

usb_device_id are not supposed to change at runtime. All functions
working with usb_device_id provided by <linux/usb.h> work with
const usb_device_id. So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
changes in v2:
              Re-submitting wireless separately.

 drivers/net/wireless/ath/ath6kl/usb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath6kl/usb.c b/drivers/net/wireless/ath/ath6kl/usb.c
index 9da3594..4defb7a 100644
--- a/drivers/net/wireless/ath/ath6kl/usb.c
+++ b/drivers/net/wireless/ath/ath6kl/usb.c
@@ -1201,7 +1201,7 @@ static int ath6kl_usb_pm_resume(struct usb_interface *interface)
 #endif
 
 /* table of devices that work with this driver */
-static struct usb_device_id ath6kl_usb_ids[] = {
+static const struct usb_device_id ath6kl_usb_ids[] = {
 	{USB_DEVICE(0x0cf3, 0x9375)},
 	{USB_DEVICE(0x0cf3, 0x9374)},
 	{ /* Terminating entry */ },
-- 
2.7.4
