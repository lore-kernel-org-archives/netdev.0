From: pierre.sauter@gmail.com
Subject: [PATCH 1/1] [PATCH] net: qmi_wwan: fix Gobi device probing for un2430
Date: Mon, 10 Sep 2012 19:02:59 +0200
Message-ID: <1347296579-15692-1-git-send-email-pierre.sauter@gmail.com>
Cc: netdev@vger.kernel.org, Pierre Sauter <pierre.sauter@gmail.com>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:47579 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750891Ab2IJRDZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 13:03:25 -0400
Received: by wibhr14 with SMTP id hr14so2504568wib.1
        for <netdev@vger.kernel.org>; Mon, 10 Sep 2012 10:03:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pierre Sauter <pierre.sauter@gmail.com>

HP un2430 is a Gobi 3000 device. It was mistakenly treated as Gobi 1000
in patch b9f90eb2740203ff2592efe640409ad48335d1c2.

I own this device and qmi_wwan works again with this fix.

Signed-off-by: Pierre Sauter <pierre.sauter@gmail.com>
---
 drivers/net/usb/qmi_wwan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index adfab3f..17b8f3e 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -398,7 +398,6 @@ static const struct usb_device_id products[] = {
 	/* 4. Gobi 1000 devices */
 	{QMI_GOBI1K_DEVICE(0x05c6, 0x9212)},	/* Acer Gobi Modem Device */
 	{QMI_GOBI1K_DEVICE(0x03f0, 0x1f1d)},	/* HP un2400 Gobi Modem Device */
-	{QMI_GOBI1K_DEVICE(0x03f0, 0x371d)},	/* HP un2430 Mobile Broadband Module */
 	{QMI_GOBI1K_DEVICE(0x04da, 0x250d)},	/* Panasonic Gobi Modem device */
 	{QMI_GOBI1K_DEVICE(0x413c, 0x8172)},	/* Dell Gobi Modem device */
 	{QMI_GOBI1K_DEVICE(0x1410, 0xa001)},	/* Novatel Gobi Modem device */
@@ -440,6 +439,7 @@ static const struct usb_device_id products[] = {
 	{QMI_GOBI_DEVICE(0x16d8, 0x8002)},	/* CMDTech Gobi 2000 Modem device (VU922) */
 	{QMI_GOBI_DEVICE(0x05c6, 0x9205)},	/* Gobi 2000 Modem device */
 	{QMI_GOBI_DEVICE(0x1199, 0x9013)},	/* Sierra Wireless Gobi 3000 Modem device (MC8355) */
+	{QMI_GOBI_DEVICE(0x03f0, 0x371d)},	/* HP un2430 Mobile Broadband Module */
 	{QMI_GOBI_DEVICE(0x1199, 0x9015)},	/* Sierra Wireless Gobi 3000 Modem device */
 	{QMI_GOBI_DEVICE(0x1199, 0x9019)},	/* Sierra Wireless Gobi 3000 Modem device */
 	{QMI_GOBI_DEVICE(0x1199, 0x901b)},	/* Sierra Wireless MC7770 */
-- 
1.7.10.4
