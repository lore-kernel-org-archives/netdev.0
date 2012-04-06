From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next #2 02/39] tehuti: stop using net_device.{base_addr, irq}.
Date: Fri,  6 Apr 2012 12:06:16 +0200
Message-ID: <7d49f20cb9a3bc4328e68a159692648e364341c8.1333704409.git.romieu@fr.zoreil.com>
References: <1333704408.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43477 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756000Ab2DFKKj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2012 06:10:39 -0400
In-Reply-To: <1333704408.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
---
 drivers/net/ethernet/tehuti/tehuti.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/tehuti/tehuti.c b/drivers/net/ethernet/tehuti/tehuti.c
index ad973ff..dc242e2 100644
--- a/drivers/net/ethernet/tehuti/tehuti.c
+++ b/drivers/net/ethernet/tehuti/tehuti.c
@@ -1988,10 +1988,6 @@ bdx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		/* these fields are used for info purposes only
 		 * so we can have them same for all ports of the board */
 		ndev->if_port = port;
-		ndev->base_addr = pciaddr;
-		ndev->mem_start = pciaddr;
-		ndev->mem_end = pciaddr + regionSize;
-		ndev->irq = pdev->irq;
 		ndev->features = NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_TSO
 		    | NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX |
 		    NETIF_F_HW_VLAN_FILTER | NETIF_F_RXCSUM
-- 
1.7.7.6
