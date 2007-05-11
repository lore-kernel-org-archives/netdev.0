From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 3/4] sky2: 88e8071 support not ready
Date: Fri, 11 May 2007 11:21:46 -0700
Message-ID: <20070511182251.461872758@linux-foundation.org>
References: <20070511182143.872814956@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:51971 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760600AbXEKSZi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 14:25:38 -0400
Content-Disposition: inline; filename=sky2-ex-disable.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver is not ready to support 88e8071 chip.
If this chip is present, system will hang on boot.

So remove it from PCI device id's for now. 

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- sky2-2.6.21.orig/drivers/net/sky2.c	2007-05-10 09:36:15.000000000 -0700
+++ sky2-2.6.21/drivers/net/sky2.c	2007-05-10 09:36:16.000000000 -0700
@@ -130,7 +130,7 @@ static const struct pci_device_id sky2_i
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4368) }, /* 88EC034 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4369) }, /* 88EC042 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x436A) }, /* 88E8058 */
-	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x436B) }, /* 88E8071 */
+//	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x436B) }, /* 88E8071 */
 	{ 0 }
 };
 

--
Stephen Hemminger <shemminger@linux-foundation.org>

