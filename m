From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH v2 10/20] libertas_tf: constify usb_device_id
Date: Wed,  9 Aug 2017 21:57:29 +0530
Message-ID: <1502296049-21253-2-git-send-email-arvind.yadav.cs@gmail.com>
References: <1502296049-21253-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org
To: kvalo@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502296049-21253-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

usb_device_id are not supposed to change at runtime. All functions
working with usb_device_id provided by <linux/usb.h> work with
const usb_device_id. So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
changes in v2:
              Re-submitting wireless separately.

 drivers/net/wireless/marvell/libertas_tf/if_usb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/marvell/libertas_tf/if_usb.c b/drivers/net/wireless/marvell/libertas_tf/if_usb.c
index e0ade40..e9104ec 100644
--- a/drivers/net/wireless/marvell/libertas_tf/if_usb.c
+++ b/drivers/net/wireless/marvell/libertas_tf/if_usb.c
@@ -31,7 +31,7 @@ module_param_named(fw_name, lbtf_fw_name, charp, 0644);
 
 MODULE_FIRMWARE("lbtf_usb.bin");
 
-static struct usb_device_id if_usb_table[] = {
+static const struct usb_device_id if_usb_table[] = {
 	/* Enter the device signature inside */
 	{ USB_DEVICE(0x1286, 0x2001) },
 	{ USB_DEVICE(0x05a3, 0x8388) },
-- 
2.7.4
