From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH V3] rtlwifi: rtl8192cu: Add new USB ID
Date: Wed, 15 May 2013 10:03:16 -0500
Message-ID: <1368630196-14704-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org, Albert Pool <albertpool@solcon.nl>,
	netdev@vger.kernel.org, Larry Finger <Larry.Finger@lwfinger.net>
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:59821 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932795Ab3EOPDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 May 2013 11:03:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Albert Pool <albertpool@solcon.nl>

This adds the USB ID of the On Networks N300MA, clone of Netgear WNA3100M.

Signed-off-by: Albert Pool <albertpool@solcon.nl>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Reported-by: Ana Rey <Anazul77@hotmail.com>
---

John,

Please use this version. V2 still had some whitespace errors that I fixed.

Albert,

Please use scripts/checkpatch.pl to check the patch before you send it.

Thanks,

Larry
---

 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
index 23d640a..18da6de 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
@@ -349,6 +349,7 @@ static struct usb_device_id rtl8192c_usb_ids[] = {
 	{RTL_USB_DEVICE(0x07aa, 0x0056, rtl92cu_hal_cfg)}, /*ATKK-Gemtek*/
 	{RTL_USB_DEVICE(0x07b8, 0x8178, rtl92cu_hal_cfg)}, /*Funai -Abocom*/
 	{RTL_USB_DEVICE(0x0846, 0x9021, rtl92cu_hal_cfg)}, /*Netgear-Sercomm*/
+	{RTL_USB_DEVICE(0x0846, 0xf001, rtl92cu_hal_cfg)}, /*On Netwrks N300MA*/
 	{RTL_USB_DEVICE(0x0b05, 0x17ab, rtl92cu_hal_cfg)}, /*ASUS-Edimax*/
 	{RTL_USB_DEVICE(0x0bda, 0x8186, rtl92cu_hal_cfg)}, /*Realtek 92CE-VAU*/
 	{RTL_USB_DEVICE(0x0df6, 0x0061, rtl92cu_hal_cfg)}, /*Sitecom-Edimax*/
-- 
1.8.1.4
