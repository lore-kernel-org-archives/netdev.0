From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2/3] sky2: add comments to PCI ids
Date: Mon, 4 Dec 2006 15:53:36 -0800
Message-ID: <20061204155336.7ee6c51f@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:36467 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935003AbWLDXxo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 18:53:44 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add comments to sky2 driver to show relationship between PCI id and
hardware.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 drivers/net/sky2.c |   48 +++++++++++++++++++++++-------------------------
 1 file changed, 23 insertions(+), 25 deletions(-)

--- sky2.orig/drivers/net/sky2.c	2006-12-04 12:47:06.000000000 -0800
+++ sky2/drivers/net/sky2.c	2006-12-04 12:47:19.000000000 -0800
@@ -100,34 +100,32 @@
 MODULE_PARM_DESC(idle_timeout, "Watchdog timer for lost interrupts (ms)");
 
 static const struct pci_device_id sky2_id_table[] = {
-	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9000) },
-	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9E00) },
+	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9000) }, /* SK-9Sxx */
+	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9E00) }, /* SK-9Exx */
 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4b00) },	/* DGE-560T */
 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4001) }, 	/* DGE-550SX */
 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4B02) },	/* DGE-560SX */
-	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4340) },
-	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4341) },
-	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4342) },
-	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4343) },
-	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4344) },
-	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4345) },
-	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4346) },
-	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4347) },
-	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4350) },
-	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4351) },
-	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4352) },
-	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4353) },
-	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4356) },
-	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4360) },
-	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4361) },
-	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4362) },
-	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4363) },
-	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4364) },
-	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4365) },
-	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4366) },
-	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4367) },
-	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4368) },
-	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4369) },
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4340) }, /* 88E8021 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4341) }, /* 88E8022 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4342) }, /* 88E8061 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4343) }, /* 88E8062 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4344) }, /* 88E8021 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4345) }, /* 88E8022 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4346) }, /* 88E8061 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4347) }, /* 88E8062 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4350) }, /* 88E8035 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4351) }, /* 88E8036 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4352) }, /* 88E8038 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4353) }, /* 88E8039 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4356) }, /* 88EC033 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4360) }, /* 88E8052 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4361) }, /* 88E8050 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4362) }, /* 88E8053 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4363) }, /* 88E8055 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4364) }, /* 88E8056 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4366) }, /* 88EC036 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4367) }, /* 88EC032 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4368) }, /* 88EC034 */
 	{ 0 }
 };
 



-- 
Stephen Hemminger <shemminger@osdl.org>
