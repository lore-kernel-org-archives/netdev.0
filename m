From: akpm@osdl.org
Subject: [patch 05/13] arcnet: SoHard PCI support
Date: Mon, 14 Aug 2006 23:03:39 -0700
Message-ID: <200608150603.k7F63dwC012936@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	stephane.witzmann@ubpmes.univ-bpclermont.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:41619 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965164AbWHOGDq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 02:03:46 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stphane Witzmann <stephane.witzmann@ubpmes.univ-bpclermont.fr>

Add support for a SoHard PCI ARCnet card.


Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/arcnet/com20020-pci.c |    1 +
 1 file changed, 1 insertion(+)

diff -puN drivers/net/arcnet/com20020-pci.c~acrnet-sohard-pci-support drivers/net/arcnet/com20020-pci.c
--- a/drivers/net/arcnet/com20020-pci.c~acrnet-sohard-pci-support
+++ a/drivers/net/arcnet/com20020-pci.c
@@ -161,6 +161,7 @@ static struct pci_device_id com20020pci_
 	{ 0x1571, 0xa204, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_CAN_10MBIT },
 	{ 0x1571, 0xa205, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_CAN_10MBIT },
 	{ 0x1571, 0xa206, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_CAN_10MBIT },
+	{ 0x10B5, 0x9030, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_CAN_10MBIT },
 	{ 0x10B5, 0x9050, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_CAN_10MBIT },
 	{0,}
 };
_
