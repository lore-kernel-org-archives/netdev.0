From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 09/20] netfilter: ipt_CLUSTERIP: create proc entry under proper ipt_CLUSTERIP directory
Date: Mon,  4 Nov 2013 22:50:31 +0100
Message-ID: <1383601842-4570-10-git-send-email-pablo@netfilter.org>
References: <1383601842-4570-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55682 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753645Ab3KDVu5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Nov 2013 16:50:57 -0500
In-Reply-To: <1383601842-4570-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>

Create proc entries under the ipt_CLUSTERIP directory of proper
net namespace.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/ipt_CLUSTERIP.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index b7fc9d5..c93dfd2 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -168,7 +168,7 @@ clusterip_config_init(const struct ipt_clusterip_tgt_info *i, __be32 ip,
 			struct net_device *dev)
 {
 	struct clusterip_config *c;
-	struct clusterip_net *cn = net_generic(&init_net, clusterip_net_id);
+	struct clusterip_net *cn = net_generic(dev_net(dev), clusterip_net_id);
 
 	c = kzalloc(sizeof(*c), GFP_ATOMIC);
 	if (!c)
-- 
1.7.10.4
