From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: [PATCH RESEND net-next 3/3] net: cdc_ncm: remove non-standard NCM device IDs
Date: Tue, 20 Aug 2013 16:50:55 +0200
Message-ID: <1377010256-19063-4-git-send-email-mrkiko.rs@gmail.com>
References: <mrkiko.rs@gmail.com>
 <1377010256-19063-1-git-send-email-mrkiko.rs@gmail.com>
Cc: Enrico Mioso <mrkiko.rs@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:65109 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751487Ab3HTOvs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 10:51:48 -0400
Received: by mail-wg0-f54.google.com with SMTP id e12so458712wgh.21
        for <netdev@vger.kernel.org>; Tue, 20 Aug 2013 07:51:47 -0700 (PDT)
In-Reply-To: <1377010256-19063-1-git-send-email-mrkiko.rs@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove device IDs of NCM-like (but not NCM-conformant) devices, that are
handled by the huawwei_cdc_ncm driver now.

Signed-off-by: Enrico Mioso <mrkiko.rs@gmail.com>
---
 drivers/net/usb/cdc_ncm.c |   11 -----------
 1 file changed, 11 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 62686be..31f43f7 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1236,17 +1236,6 @@ static const struct usb_device_id cdc_devs[] = {
 	  .driver_info = (unsigned long)&wwan_info,
 	},
 
-	/* Huawei NCM devices disguised as vendor specific */
-	{ USB_VENDOR_AND_INTERFACE_INFO(0x12d1, 0xff, 0x02, 0x16),
-	  .driver_info = (unsigned long)&wwan_info,
-	},
-	{ USB_VENDOR_AND_INTERFACE_INFO(0x12d1, 0xff, 0x02, 0x46),
-	  .driver_info = (unsigned long)&wwan_info,
-	},
-	{ USB_VENDOR_AND_INTERFACE_INFO(0x12d1, 0xff, 0x02, 0x76),
-	  .driver_info = (unsigned long)&wwan_info,
-	},
-
 	/* Infineon(now Intel) HSPA Modem platform */
 	{ USB_DEVICE_AND_INTERFACE_INFO(0x1519, 0x0443,
 		USB_CLASS_COMM,
-- 
1.7.10.4
