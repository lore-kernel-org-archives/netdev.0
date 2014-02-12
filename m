From: Aleksander Morgado <aleksander@aleksander.es>
Subject: [PATCH] net: qmi_wwan: add support for Cinterion PXS8 and PHS8
Date: Wed, 12 Feb 2014 15:55:14 +0100
Message-ID: <1392216914-11520-1-git-send-email-aleksander@aleksander.es>
Cc: bjorn@mork.no, netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Aleksander Morgado <aleksander@aleksander.es>,
	Hans-Christoph Schemmel <hans-christoph.schemmel@gemalto.com>,
	Christian Schmiedl <christian.schmiedl@gemalto.com>,
	Nicolaus Colberg <nicolaus.colberg@gemalto.com>,
	David McCullough <david.mccullough@accelecon.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:61442 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751218AbaBLO4D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 09:56:03 -0500
Received: by mail-wi0-f176.google.com with SMTP id hi5so7056012wib.3
        for <netdev@vger.kernel.org>; Wed, 12 Feb 2014 06:56:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the PXS8 and PHS8 devices show up with PID 0x0053 they will expose both a
QMI port and a WWAN interface.

CC: Hans-Christoph Schemmel <hans-christoph.schemmel@gemalto.com>
CC: Christian Schmiedl <christian.schmiedl@gemalto.com>
CC: Nicolaus Colberg <nicolaus.colberg@gemalto.com>
CC: David McCullough <david.mccullough@accelecon.com>
Signed-off-by: Aleksander Morgado <aleksander@aleksander.es>
---
 drivers/net/usb/qmi_wwan.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index ff5c871..1eddd43 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -732,6 +732,7 @@ static const struct usb_device_id products[] = {
 	{QMI_FIXED_INTF(0x1bc7, 0x1201, 2)},	/* Telit LE920 */
 	{QMI_FIXED_INTF(0x0b3c, 0xc005, 6)},    /* Olivetti Olicard 200 */
 	{QMI_FIXED_INTF(0x1e2d, 0x0060, 4)},	/* Cinterion PLxx */
+	{QMI_FIXED_INTF(0x1e2d, 0x0053, 4)},	/* Cinterion PHxx,PXxx */
 
 	/* 4. Gobi 1000 devices */
 	{QMI_GOBI1K_DEVICE(0x05c6, 0x9212)},	/* Acer Gobi Modem Device */
-- 
1.8.5.3
