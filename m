From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 02/34] tehuti: stop using net_device.{base_addr, irq}.
Date: Thu, 15 Mar 2012 14:56:59 +0100
Message-ID: <333fbbccca8915c988acc82e0aae84e3c4f42283.1331814082.git.romieu@fr.zoreil.com>
References: <cover.1331814082.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51800 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752868Ab2CON7b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2012 09:59:31 -0400
In-Reply-To: <cover.1331814082.git.romieu@fr.zoreil.com>
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
