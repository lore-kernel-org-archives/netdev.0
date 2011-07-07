From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/4] skge: cleanup pci id table
Date: Wed, 06 Jul 2011 22:00:05 -0700
Message-ID: <20110707050048.912475809@vyatta.com>
References: <20110707050003.998140428@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42590 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751393Ab1GGFBP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jul 2011 01:01:15 -0400
Content-Disposition: inline; filename=skge-pci-id.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PCI table was using mix of defines for device id and hard coded
hex values. This patch change it to all hex values. It also adds
comments based on the names provided in the vendor driver table.

There is NO CHANGE to the actual resulting table.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/skge.c	2011-06-08 09:08:33.000000000 -0700
+++ b/drivers/net/skge.c	2011-07-06 18:33:07.299999438 -0700
@@ -83,17 +83,16 @@ module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
 
 static DEFINE_PCI_DEVICE_TABLE(skge_id_table) = {
-	{ PCI_DEVICE(PCI_VENDOR_ID_3COM, PCI_DEVICE_ID_3COM_3C940) },
-	{ PCI_DEVICE(PCI_VENDOR_ID_3COM, PCI_DEVICE_ID_3COM_3C940B) },
-	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_GE) },
-	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_YU) },
-	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, PCI_DEVICE_ID_DLINK_DGE510T) },
-	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4b01) },	/* DGE-530T */
-	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4320) },
-	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x5005) }, /* Belkin */
-	{ PCI_DEVICE(PCI_VENDOR_ID_CNET, PCI_DEVICE_ID_CNET_GIGACARD) },
-	{ PCI_DEVICE(PCI_VENDOR_ID_LINKSYS, PCI_DEVICE_ID_LINKSYS_EG1064) },
-	{ PCI_VENDOR_ID_LINKSYS, 0x1032, PCI_ANY_ID, 0x0015 },
+	{ PCI_DEVICE(PCI_VENDOR_ID_3COM, 0x1700) },	  /* 3Com 3C940 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_3COM, 0x80EB) },	  /* 3Com 3C940B */
+	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x4320) }, /* SK-98xx V2.0 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4b01) },	  /* D-Link DGE-530T (rev.B) */
+	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4c00) },	  /* D-Link DGE-530T */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4320) },	  /* Marvell Yukon 88E8001/8003/8010 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x5005) },	  /* Belkin */
+	{ PCI_DEVICE(PCI_VENDOR_ID_CNET, 0x434E) }, 	  /* CNet PowerG-2000 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_LINKSYS, 0x1064) },	  /* Linksys EG1064 v2 */
+	{ PCI_VENDOR_ID_LINKSYS, 0x1032, PCI_ANY_ID, 0x0015 }, /* Linksys EG1032 v2 */
 	{ 0 }
 };
 MODULE_DEVICE_TABLE(pci, skge_id_table);


