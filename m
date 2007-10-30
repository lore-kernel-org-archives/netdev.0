From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: [PATCH] DM9601: Support for ADMtek ADM8515 NIC
Date: Tue, 30 Oct 2007 14:23:47 +0100
Message-ID: <87pryw68ik.fsf@macbook.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.186]:55887 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750997AbXJ3NYt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 09:24:49 -0400
Received: by fk-out-0910.google.com with SMTP id z23so1900966fkz
        for <netdev@vger.kernel.org>; Tue, 30 Oct 2007 06:24:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add device ID for the ADMtek ADM8515 USB NIC to the DM9601 driver.

Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>

diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index a2de32f..2c68573 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -586,6 +586,10 @@ static const struct usb_device_id products[] = {
 	 USB_DEVICE(0x0a46, 0x0268),	/* ShanTou ST268 USB NIC */
 	 .driver_info = (unsigned long)&dm9601_info,
 	 },
+	{
+	 USB_DEVICE(0x0a46, 0x8515),	/* ADMtek ADM8515 USB NIC */
+	 .driver_info = (unsigned long)&dm9601_info,
+	 },
 	{},			// END
 };
 
-- 
1.5.3.4

-- 
Bye, Peter Korsgaard
