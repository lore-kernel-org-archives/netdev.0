From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] bridge: make ifla_br_policy and br_af_ops static
Date: Thu, 14 Feb 2013 13:57:12 +0800
Message-ID: <1360821432-28155-1-git-send-email-amwang@redhat.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22163 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750990Ab3BNF50 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2013 00:57:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

They are only used within this file.

Cc: Vlad Yasevich <vyasevic@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index d1dda47..27aa3ee 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -217,7 +217,7 @@ out:
 	return err;
 }
 
-const struct nla_policy ifla_br_policy[IFLA_MAX+1] = {
+static const struct nla_policy ifla_br_policy[IFLA_MAX+1] = {
 	[IFLA_BRIDGE_FLAGS]	= { .type = NLA_U16 },
 	[IFLA_BRIDGE_MODE]	= { .type = NLA_U16 },
 	[IFLA_BRIDGE_VLAN_INFO]	= { .type = NLA_BINARY,
@@ -463,7 +463,7 @@ static size_t br_get_link_af_size(const struct net_device *dev)
 	return pv->num_vlans * nla_total_size(sizeof(struct bridge_vlan_info));
 }
 
-struct rtnl_af_ops br_af_ops = {
+static struct rtnl_af_ops br_af_ops = {
 	.family			= AF_BRIDGE,
 	.get_link_af_size	= br_get_link_af_size,
 };
