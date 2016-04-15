From: Govindarajulu Varadarajan <gvaradar@cisco.com>
Subject: [PATCH net-next] enic: set netdev->vlan_features
Date: Sat, 16 Apr 2016 00:40:43 +0530
Message-ID: <1460747443-14993-1-git-send-email-gvaradar@cisco.com>
Cc: benve@cisco.com, mkubecek@suse.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgl-iport-2.cisco.com ([72.163.197.26]:17105 "EHLO
	bgl-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753078AbcDOTV5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 15:21:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>

Driver sets vlan_feature to netdev->features as hardware supports all of
them on vlan interface.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/enic_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index b2182d3..f15560a 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -2740,6 +2740,7 @@ static int enic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		netdev->hw_features |= NETIF_F_RXCSUM;
 
 	netdev->features |= netdev->hw_features;
+	netdev->vlan_features |= netdev->features;
 
 #ifdef CONFIG_RFS_ACCEL
 	netdev->hw_features |= NETIF_F_NTUPLE;
-- 
2.8.0
