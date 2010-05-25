From: f.aben@option.com
Subject: [PATCH] hso: add support for new products
Date: Tue, 25 May 2010 14:33:01 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.1005251402310.2667@filip-linux>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	j.dumon@option.com
To: davem@davemloft.net, gregkh@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.option.com ([81.246.70.162]:26052 "EHLO
	mailer1.option.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752720Ab0EYMnS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 May 2010 08:43:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch adds a few new product id's for the hso driver.

Signed-off-by: Filip Aben <f.aben@option.com>
---
diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index be0cc99..8355f0e 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -475,6 +475,9 @@ static const struct usb_device_id hso_ids[] = {
 	{USB_DEVICE(0x0af0, 0x8302)},
 	{USB_DEVICE(0x0af0, 0x8304)},
 	{USB_DEVICE(0x0af0, 0x8400)},
+	{USB_DEVICE(0x0af0, 0x8600)},
+	{USB_DEVICE(0x0af0, 0x8800)},
+	{USB_DEVICE(0x0af0, 0x8900)},
 	{USB_DEVICE(0x0af0, 0xd035)},
 	{USB_DEVICE(0x0af0, 0xd055)},
 	{USB_DEVICE(0x0af0, 0xd155)},
