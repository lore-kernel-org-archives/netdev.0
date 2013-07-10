From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: [PATCH 3/3] net: cdc_ncm: remove Huawei non-standard NCM device
 IDs
Date: Wed, 10 Jul 2013 14:30:22 +0200 (CEST)
Message-ID: <alpine.LNX.2.02.1307101428550.22696@eeeadesso>
References: <alpine.LNX.2.02.1307021241380.8884@eeeadesso> <87wqp9xja5.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: =?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f178.google.com ([209.85.215.178]:56088 "EHLO
	mail-ea0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753981Ab3GJM37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 08:29:59 -0400
Received: by mail-ea0-f178.google.com with SMTP id l15so4838042eak.23
        for <netdev@vger.kernel.org>; Wed, 10 Jul 2013 05:29:58 -0700 (PDT)
In-Reply-To: <87wqp9xja5.fsf@nemi.mork.no>
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
