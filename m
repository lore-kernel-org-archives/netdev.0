From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 4/6] sky2: 88e8071 support not ready
Date: Tue, 15 May 2007 15:08:25 -0700
Message-ID: <20070515220903.737015029@linux-foundation.org>
References: <20070515220821.676720721@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42920 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756482AbXEOWTV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2007 18:19:21 -0400
Content-Disposition: inline; filename=sky2-ex-disable.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver is not ready to support 88e8071 chip, it requires several
more changes (not done yet). If this chip is present, system will hang on boot.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.21.y.orig/drivers/net/sky2.c	2007-05-15 09:07:11.000000000 -0700
+++ linux-2.6.21.y/drivers/net/sky2.c	2007-05-15 09:07:14.000000000 -0700
@@ -129,7 +129,7 @@ static const struct pci_device_id sky2_i
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4368) }, /* 88EC034 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4369) }, /* 88EC042 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x436A) }, /* 88E8058 */
-	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x436B) }, /* 88E8071 */
+//	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x436B) }, /* 88E8071 */
 	{ 0 }
 };
 

--
Stephen Hemminger <shemminger@linux-foundation.org>

