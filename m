From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/9] e1000: Combining Bitwise OR in one expression.
Date: Wed, 20 Jun 2012 01:44:55 -0700
Message-ID: <1340181903-16382-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1340181903-16382-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Tushar Dave <tushar.n.dave@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:31665 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753136Ab2FTIpG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2012 04:45:06 -0400
In-Reply-To: <1340181903-16382-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tushar Dave <tushar.n.dave@intel.com>

Signed-off-by: Tushar Dave <tushar.n.dave@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 7483ca0..183a4a3 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -1078,18 +1078,18 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	netdev->priv_flags |= IFF_SUPP_NOFCS;
 
 	netdev->features |= netdev->hw_features;
-	netdev->hw_features |= NETIF_F_RXCSUM;
-	netdev->hw_features |= NETIF_F_RXALL;
-	netdev->hw_features |= NETIF_F_RXFCS;
+	netdev->hw_features |= (NETIF_F_RXCSUM |
+				NETIF_F_RXALL |
+				NETIF_F_RXFCS);
 
 	if (pci_using_dac) {
 		netdev->features |= NETIF_F_HIGHDMA;
 		netdev->vlan_features |= NETIF_F_HIGHDMA;
 	}
 
-	netdev->vlan_features |= NETIF_F_TSO;
-	netdev->vlan_features |= NETIF_F_HW_CSUM;
-	netdev->vlan_features |= NETIF_F_SG;
+	netdev->vlan_features |= (NETIF_F_TSO |
+				  NETIF_F_HW_CSUM |
+				  NETIF_F_SG);
 
 	netdev->priv_flags |= IFF_UNICAST_FLT;
 
-- 
1.7.10.2
