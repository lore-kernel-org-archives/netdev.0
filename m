From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: [PATCH] dm9601: add Hirose USB-100 device ID
Date: Tue, 18 Mar 2008 23:16:53 +0100
Message-ID: <1205878614-29065-2-git-send-email-jacmet@sunsite.dk>
References: <1205878614-29065-1-git-send-email-jacmet@sunsite.dk>
Cc: Peter Korsgaard <jacmet@sunsite.dk>
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:20061 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756422AbYCSWFK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 18:05:10 -0400
Received: by nf-out-0910.google.com with SMTP id g13so358252nfb.21
        for <netdev@vger.kernel.org>; Wed, 19 Mar 2008 15:05:08 -0700 (PDT)
In-Reply-To: <1205878614-29065-1-git-send-email-jacmet@sunsite.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Hirose USB-100 adapter uses a dm9601 chip.
Reported by Robert Brockway.

Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
---
 drivers/net/usb/dm9601.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index 96082fd..1821778 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -562,6 +562,10 @@ static const struct usb_device_id products[] = {
 	 USB_DEVICE(0x0a46, 0x8515),	/* ADMtek ADM8515 USB NIC */
 	 .driver_info = (unsigned long)&dm9601_info,
 	 },
+	{
+	USB_DEVICE(0x0a47, 0x9601),	/* Hirose USB-100 */
+	.driver_info = (unsigned long)&dm9601_info,
+	 },
 	{},			// END
 };
 
-- 
1.5.4.1

