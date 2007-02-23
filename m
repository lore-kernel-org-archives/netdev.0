From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 5/6] sky2: add more pci ids
Date: Fri, 23 Feb 2007 15:10:47 -0800
Message-ID: <20070223231353.674323000@linux-foundation.org>
References: <20070223231042.860031000@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:40979 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933268AbXBWXRd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Feb 2007 18:17:33 -0500
Content-Disposition: inline; filename=sky2-pci-ids.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update the pci device id table to match 2.6.20 (except for new 88e807x
that is still experimental).

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |   48 +++++++++++++++++++++++++++++-------------------
 1 file changed, 29 insertions(+), 19 deletions(-)

--- linux-2.6.16.y.orig/drivers/net/sky2.c	2007-02-23 14:45:39.000000000 -0800
+++ linux-2.6.16.y/drivers/net/sky2.c	2007-02-23 14:45:42.000000000 -0800
@@ -97,25 +97,35 @@
 MODULE_PARM_DESC(copybreak, "Receive copy threshold");
 
 static const struct pci_device_id sky2_id_table[] = {
-	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9000) },
-	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9E00) },
-	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4b00) },
-	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4b01) },
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
-	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4360) },
-	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4361) },
-	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4362) },
-	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4363) },
+	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9000) }, /* SK-9Sxx */
+	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9E00) }, /* SK-9Exx */
+	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4b00) },	/* DGE-560T */
+	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4001) }, 	/* DGE-550SX */
+	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4B02) },	/* DGE-560SX */
+	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4B03) },	/* DGE-550T */
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
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4369) }, /* 88EC042 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x436A) }, /* 88E8058 */
 	{ 0 }
 };
 

--
Stephen Hemminger <shemminger@linux-foundation.org>

