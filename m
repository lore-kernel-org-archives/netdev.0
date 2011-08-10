From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 2/2] rtnetlink: remove initialization of dev->real_num_tx_queues
Date: Wed, 10 Aug 2011 18:09:45 +0200
Message-ID: <1312992585-1201-3-git-send-email-jpirko@redhat.com>
References: <1312992585-1201-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, fubar@us.ibm.com,
	andy@greyhouse.net, tgraf@infradead.org, ebiederm@xmission.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27139 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751709Ab1HJQKR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Aug 2011 12:10:17 -0400
In-Reply-To: <1312992585-1201-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev->real_num_tx_queues is correctly set already in alloc_netdev_mqs.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 net/core/rtnetlink.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 99d9e95..39f8dd6 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1604,7 +1604,6 @@ struct net_device *rtnl_create_link(struct net *src_net, struct net *net,
 	dev_net_set(dev, net);
 	dev->rtnl_link_ops = ops;
 	dev->rtnl_link_state = RTNL_LINK_INITIALIZING;
-	dev->real_num_tx_queues = real_num_queues;
 
 	if (tb[IFLA_MTU])
 		dev->mtu = nla_get_u32(tb[IFLA_MTU]);
-- 
1.7.6

