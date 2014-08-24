From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] staging: r8188eu: Add new USB ID
Date: Sun, 24 Aug 2014 11:30:18 -0500
Message-ID: <1408897818-15432-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:55976 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752793AbaHXQaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Aug 2014 12:30:30 -0400
Received: by mail-oi0-f51.google.com with SMTP id v63so2045712oia.24
        for <netdev@vger.kernel.org>; Sun, 24 Aug 2014 09:30:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Elecom WDC-150SU2M uses this chip.

Reported-by: Hiroki Kondo <kompiro@gmail.com>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/os_dep/usb_intf.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/staging/rtl8188eu/os_dep/usb_intf.c b/drivers/staging/rtl8188eu/os_dep/usb_intf.c
index 264e639..407a318 100644
--- a/drivers/staging/rtl8188eu/os_dep/usb_intf.c
+++ b/drivers/staging/rtl8188eu/os_dep/usb_intf.c
@@ -43,6 +43,7 @@ static struct usb_device_id rtw_usb_id_tbl[] = {
 	{USB_DEVICE(USB_VENDER_ID_REALTEK, 0x0179)}, /* 8188ETV */
 	/*=== Customer ID ===*/
 	/****** 8188EUS ********/
+	{USB_DEVICE(0x056e, 0x4008)}, /* Elecom WDC-150SU2M */
 	{USB_DEVICE(0x07b8, 0x8179)}, /* Abocom - Abocom */
 	{USB_DEVICE(0x2001, 0x330F)}, /* DLink DWA-125 REV D1 */
 	{USB_DEVICE(0x2001, 0x3310)}, /* Dlink DWA-123 REV D1 */
-- 
1.8.4.5
