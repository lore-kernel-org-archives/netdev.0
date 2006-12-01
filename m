From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2/5] sky2: add Dlink 560SX id
Date: Fri, 01 Dec 2006 14:29:34 -0800
Message-ID: <20061201223218.861889042@osdl.org>
References: <20061201222931.730523290@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:15289 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1162125AbWLAWen (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Dec 2006 17:34:43 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-dlink.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add new PCI ID for DLink 560SX.
This from the latest SysKonnect vendor driver (version 8.41).

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 drivers/net/sky2.c |    1 +
 1 file changed, 1 insertion(+)

--- netdev-2.6.orig/drivers/net/sky2.c	2006-12-01 14:23:21.000000000 -0800
+++ netdev-2.6/drivers/net/sky2.c	2006-12-01 14:23:27.000000000 -0800
@@ -104,6 +104,7 @@
 	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9E00) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4b00) },	/* DGE-560T */
 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4001) }, 	/* DGE-550SX */
+	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4B02) },	/* DGE-560SX */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4340) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4341) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4342) },

--
Stephen Hemminger <shemminger@osdl.org>

