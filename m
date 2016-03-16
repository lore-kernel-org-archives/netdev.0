From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next 2/2] team: remove duplicate set of flag IFF_MULTICAST
Date: Wed, 16 Mar 2016 09:59:16 +0000
Message-ID: <1458122356-25021-3-git-send-email-zhangshengju@cmss.chinamobile.com>
References: <1458122356-25021-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, j.vosburgh@gmail.com, jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:8833 "EHLO
	cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934679AbcCPJyz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 05:54:55 -0400
In-Reply-To: <1458122356-25021-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unnecessary set of flag IFF_MULTICAST, since ether_setup
already does this.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 drivers/net/team/team.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 2769835..26c64d2 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -2082,7 +2082,6 @@ static void team_setup(struct net_device *dev)
 	dev->netdev_ops = &team_netdev_ops;
 	dev->ethtool_ops = &team_ethtool_ops;
 	dev->destructor	= team_destructor;
-	dev->flags |= IFF_MULTICAST;
 	dev->priv_flags &= ~(IFF_XMIT_DST_RELEASE | IFF_TX_SKB_SHARING);
 	dev->priv_flags |= IFF_NO_QUEUE;
 	dev->priv_flags |= IFF_TEAM;
-- 
1.8.3.1
