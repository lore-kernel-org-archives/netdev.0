From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: [PATCH] dm9601: new vendor/product IDs
Date: Tue,  3 Mar 2009 16:22:59 +0100
Message-ID: <1236093779-27089-1-git-send-email-jacmet@sunsite.dk>
Cc: eric@linux.ca, Peter Korsgaard <jacmet@sunsite.dk>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f177.google.com ([209.85.219.177]:54849 "EHLO
	mail-ew0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756742AbZCCPXG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 10:23:06 -0500
Received: by ewy25 with SMTP id 25so2357767ewy.37
        for <netdev@vger.kernel.org>; Tue, 03 Mar 2009 07:23:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add vendor/product IDs for new no name dm9601 compatible usb ethernet
adaptors.

Reported-by: Eric Lauriault <eric@linux.ca>
Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
---
 drivers/net/usb/dm9601.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index 5b67bbf..81682c6 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -635,6 +635,10 @@ static const struct usb_device_id products[] = {
 	USB_DEVICE(0x0a47, 0x9601),	/* Hirose USB-100 */
 	.driver_info = (unsigned long)&dm9601_info,
 	 },
+	{
+	USB_DEVICE(0x0fe6, 0x8101),	/* DM9601 USB to Fast Ethernet Adapter */
+	.driver_info = (unsigned long)&dm9601_info,
+	 },
 	{},			// END
 };
 
-- 
1.5.6.5

