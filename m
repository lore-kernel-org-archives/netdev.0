From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next] fjes: remove duplicate set of flag IFF_BROADCAST
Date: Tue, 13 Jun 2017 20:49:49 +0800
Message-ID: <1497358189-3342-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: davem@davemloft.net, izumi.taku@jp.fujitsu.com,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:12404 "EHLO
        cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752233AbdFMMt6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 08:49:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unnecessary set of flag IFF_BROADCAST, since ether_setup
already does this.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 drivers/net/fjes/fjes_main.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index ae48c80..b56e07f 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -1348,7 +1348,6 @@ static void fjes_netdev_setup(struct net_device *netdev)
 	netdev->mtu = fjes_support_mtu[3];
 	netdev->min_mtu = fjes_support_mtu[0];
 	netdev->max_mtu = fjes_support_mtu[3];
-	netdev->flags |= IFF_BROADCAST;
 	netdev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
 }
 
-- 
1.8.3.1
