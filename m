From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH v2 11/20] mwifiex: constify usb_device_id
Date: Wed,  9 Aug 2017 21:57:59 +0530
Message-ID: <1502296079-21307-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org
To: kvalo@codeaurora.org, amitkarwar@gmail.com, nishants@marvell.com,
        gbhat@marvell.com, huxm@marvell.com
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

 drivers/net/wireless/marvell/mwifiex/usb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/marvell/mwifiex/usb.c b/drivers/net/wireless/marvell/mwifiex/usb.c
index cb1753e..821a77b 100644
--- a/drivers/net/wireless/marvell/mwifiex/usb.c
+++ b/drivers/net/wireless/marvell/mwifiex/usb.c
@@ -24,7 +24,7 @@
 
 static struct mwifiex_if_ops usb_ops;
 
-static struct usb_device_id mwifiex_usb_table[] = {
+static const struct usb_device_id mwifiex_usb_table[] = {
 	/* 8766 */
 	{USB_DEVICE(USB8XXX_VID, USB8766_PID_1)},
 	{USB_DEVICE_AND_INTERFACE_INFO(USB8XXX_VID, USB8766_PID_2,
-- 
2.7.4
