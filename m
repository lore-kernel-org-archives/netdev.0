From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next 1/2] bonding: remove duplicate set of flag IFF_MULTICAST
Date: Wed, 16 Mar 2016 09:59:15 +0000
Message-ID: <1458122356-25021-2-git-send-email-zhangshengju@cmss.chinamobile.com>
References: <1458122356-25021-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, j.vosburgh@gmail.com, jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta2.chinamobile.com ([221.176.66.80]:3945 "EHLO
	cmccmta2.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932327AbcCPJyx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 05:54:53 -0400
In-Reply-To: <1458122356-25021-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unnecessary set of flag IFF_MULTICAST, since ether_setup
already does this.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 drivers/net/bonding/bond_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index b6236ff..270b39c 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4175,7 +4175,7 @@ void bond_setup(struct net_device *bond_dev)
 	SET_NETDEV_DEVTYPE(bond_dev, &bond_type);
 
 	/* Initialize the device options */
-	bond_dev->flags |= IFF_MASTER|IFF_MULTICAST;
+	bond_dev->flags |= IFF_MASTER;
 	bond_dev->priv_flags |= IFF_BONDING | IFF_UNICAST_FLT | IFF_NO_QUEUE;
 	bond_dev->priv_flags &= ~(IFF_XMIT_DST_RELEASE | IFF_TX_SKB_SHARING);
 
-- 
1.8.3.1
