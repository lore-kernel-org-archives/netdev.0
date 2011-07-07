From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/4] add pci-id for DGE-530T
Date: Wed, 06 Jul 2011 22:00:06 -0700
Message-ID: <20110707050048.998166201@vyatta.com>
References: <20110707050003.998140428@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42593 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751285Ab1GGFBP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jul 2011 01:01:15 -0400
Content-Disposition: inline; filename=skge-add-dlink.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

See also: https://bugzilla.kernel.org/show_bug.cgi?id=38862

Reported-by: jameshenderson@ruggedcom.com

--- a/drivers/net/skge.c	2011-07-06 19:27:02.459999149 -0700
+++ b/drivers/net/skge.c	2011-07-06 19:28:58.836000719 -0700
@@ -88,6 +88,7 @@ static DEFINE_PCI_DEVICE_TABLE(skge_id_t
 	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x4320) }, /* SK-98xx V2.0 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4b01) },	  /* D-Link DGE-530T (rev.B) */
 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4c00) },	  /* D-Link DGE-530T */
+	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4302) },	  /* D-Link DGE-530T Rev C1 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4320) },	  /* Marvell Yukon 88E8001/8003/8010 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x5005) },	  /* Belkin */
 	{ PCI_DEVICE(PCI_VENDOR_ID_CNET, 0x434E) }, 	  /* CNet PowerG-2000 */


