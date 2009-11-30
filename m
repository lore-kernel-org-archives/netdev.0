From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH net-next-2.6 1/6] be2net: set netdev->vlan_features
 appropriately
Date: Mon, 30 Nov 2009 09:24:54 +0530
Message-ID: <20091130035444.GA15426@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:29428 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752712AbZK3Dyr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 22:54:47 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

patch to initialize netdev->vlan_features appropriately.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 7959364..2c84c92 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1951,6 +1951,8 @@ static void be_netdev_init(struct net_device *netdev)
 		NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_FILTER | NETIF_F_HW_CSUM |
 		NETIF_F_GRO;
 
+	netdev->vlan_features |= NETIF_F_SG | NETIF_F_TSO | NETIF_F_HW_CSUM;
+
 	netdev->flags |= IFF_MULTICAST;
 
 	adapter->rx_csum = true;
-- 
1.6.3.3

