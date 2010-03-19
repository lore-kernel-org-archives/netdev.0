From: Vasanthy Kolluri <vkolluri@cisco.com>
Subject: [net-next PATCH 3/5] enic: Do not advertise NETIF_F_HW_VLAN_RX
Date: Thu, 18 Mar 2010 19:19:54 -0700
Message-ID: <20100319021954.10527.16648.stgit@savbu-pc100.cisco.com>
References: <20100319021901.10527.9869.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:57708 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751889Ab0CSCTy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 22:19:54 -0400
In-Reply-To: <20100319021901.10527.9869.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>

Hardware does not honor vlan filters from the host and so the driver does
not need to advertise this.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
---
 drivers/net/enic/enic_main.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index cf098bb..18c043a 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -2058,8 +2058,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	netdev->watchdog_timeo = 2 * HZ;
 	netdev->ethtool_ops = &enic_ethtool_ops;
 
-	netdev->features |= NETIF_F_HW_VLAN_TX |
-		NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER;
+	netdev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 	if (ENIC_SETTING(enic, TXCSUM))
 		netdev->features |= NETIF_F_SG | NETIF_F_HW_CSUM;
 	if (ENIC_SETTING(enic, TSO))

