From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 3/6] sky2: allow 88E8056
Date: Tue, 15 May 2007 15:08:24 -0700
Message-ID: <20070515220903.648019094@linux-foundation.org>
References: <20070515220821.676720721@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42856 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756553AbXEOWT2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2007 18:19:28 -0400
Content-Disposition: inline; filename=sky2-88e8056-allow.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It looks like the problems of Gigabyte 88E8056 are unique to that chip
motherboard and maybe fixable by EEPROM update.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |    3 ---
 1 file changed, 3 deletions(-)

--- linux-2.6.21.y.orig/drivers/net/sky2.c	2007-05-15 09:06:58.000000000 -0700
+++ linux-2.6.21.y/drivers/net/sky2.c	2007-05-15 09:07:11.000000000 -0700
@@ -123,10 +123,7 @@ static const struct pci_device_id sky2_i
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4361) }, /* 88E8050 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4362) }, /* 88E8053 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4363) }, /* 88E8055 */
-#ifdef broken
-	/* This device causes data corruption problems that are not resolved */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4364) }, /* 88E8056 */
-#endif
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4366) }, /* 88EC036 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4367) }, /* 88EC032 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4368) }, /* 88EC034 */

--
Stephen Hemminger <shemminger@linux-foundation.org>

