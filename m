From: Joerie de Gram <j.de.gram@gmail.com>
Subject: [PATCH] tg3: Add BCM57766 to PCI device table
Date: Fri,  8 Feb 2013 00:31:04 +0100
Message-ID: <1360279864-8732-1-git-send-email-j.de.gram@gmail.com>
Cc: netdev@vger.kernel.org
To: mcarlson@broadcom.com, mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f177.google.com ([74.125.82.177]:40752 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759525Ab3BGXcw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 18:32:52 -0500
Received: by mail-we0-f177.google.com with SMTP id d7so2531236wer.36
        for <netdev@vger.kernel.org>; Thu, 07 Feb 2013 15:32:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The BCM57766 (as found in recent Apple mac mini models) appears to be
supported by the driver, but lacks an entry in the PCI device table.

Signed-off-by: Joerie de Gram <j.de.gram@gmail.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index bdb0869..214b27e 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -323,6 +323,7 @@ static DEFINE_PCI_DEVICE_TABLE(tg3_pci_tbl) = {
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57785)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57761)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57765)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57766)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57791),
 	 .driver_data = TG3_DRV_DATA_FLAG_10_100_ONLY},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57795),
-- 
1.8.1.2
