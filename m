From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] rtlwifi: rtl8192cu: Add new USB ID
Date: Fri,  8 Feb 2013 12:28:18 -0600
Message-ID: <1360348098-8687-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:51141 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946611Ab3BHS2q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 13:28:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A new model of the RTL8188CUS has appeared.

Reported-and-tested-by: Thomas Rosenkrantz <tom.rosary@googlemail.com>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Stable <stable@vger.kernel.org>
---
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
index 577c0dc..a73a17b 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
@@ -285,6 +285,7 @@ static struct usb_device_id rtl8192c_usb_ids[] = {
 	{RTL_USB_DEVICE(USB_VENDER_ID_REALTEK, 0x817f, rtl92cu_hal_cfg)},
 	/* RTL8188CUS-VL */
 	{RTL_USB_DEVICE(USB_VENDER_ID_REALTEK, 0x818a, rtl92cu_hal_cfg)},
+	{RTL_USB_DEVICE(USB_VENDER_ID_REALTEK, 0x819a, rtl92cu_hal_cfg)},
 	/* 8188 Combo for BC4 */
 	{RTL_USB_DEVICE(USB_VENDER_ID_REALTEK, 0x8754, rtl92cu_hal_cfg)},
 
-- 
1.8.1
