From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 14/35] net: usb: r8152: constify usb_device_id
Date: Tue,  8 Aug 2017 21:28:05 +0530
Message-ID: <1502207885-11574-5-git-send-email-arvind.yadav.cs@gmail.com>
References: <1502207885-11574-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org
To: kvalo@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34875 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752683AbdHHP6g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 11:58:36 -0400
In-Reply-To: <1502207885-11574-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

usb_device_id are not supposed to change at runtime. All functions
working with usb_device_id provided by <linux/usb.h> work with
const usb_device_id. So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/usb/r8152.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 6cfffef..ceb78e2 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -5303,7 +5303,7 @@ static void rtl8152_disconnect(struct usb_interface *intf)
 	.bInterfaceProtocol = USB_CDC_PROTO_NONE
 
 /* table of devices that work with this driver */
-static struct usb_device_id rtl8152_table[] = {
+static const struct usb_device_id rtl8152_table[] = {
 	{REALTEK_USB_DEVICE(VENDOR_ID_REALTEK, 0x8050)},
 	{REALTEK_USB_DEVICE(VENDOR_ID_REALTEK, 0x8152)},
 	{REALTEK_USB_DEVICE(VENDOR_ID_REALTEK, 0x8153)},
-- 
2.7.4
