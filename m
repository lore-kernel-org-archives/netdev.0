From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH 7/9] net-bridge: Convert (hw_/vlan_/wanted_)features fields from u32 type to u64.
Date: Fri, 22 Apr 2011 16:36:05 -0700
Message-ID: <1303515367-25595-8-git-send-email-maheshb@google.com>
References: <1303515367-25595-1-git-send-email-maheshb@google.com>
 <1303515367-25595-2-git-send-email-maheshb@google.com>
 <1303515367-25595-3-git-send-email-maheshb@google.com>
 <1303515367-25595-4-git-send-email-maheshb@google.com>
 <1303515367-25595-5-git-send-email-maheshb@google.com>
 <1303515367-25595-6-git-send-email-maheshb@google.com>
 <1303515367-25595-7-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:28959 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757051Ab1DVXgU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2011 19:36:20 -0400
In-Reply-To: <1303515367-25595-7-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 net/bridge/br_if.c      |    2 +-
 net/bridge/br_private.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 7f5379c..6455f52 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -294,7 +294,7 @@ int br_min_mtu(const struct net_bridge *br)
 void br_features_recompute(struct net_bridge *br)
 {
 	struct net_bridge_port *p;
-	u32 features, mask;
+	u64 features, mask;
 
 	features = mask = br->feature_mask;
 	if (list_empty(&br->port_list))
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index e2a4034..1ac4020 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -183,7 +183,7 @@ struct net_bridge
 	struct br_cpu_netstats __percpu *stats;
 	spinlock_t			hash_lock;
 	struct hlist_head		hash[BR_HASH_SIZE];
-	u32				feature_mask;
+	u64				feature_mask;
 #ifdef CONFIG_BRIDGE_NETFILTER
 	struct rtable 			fake_rtable;
 	bool				nf_call_iptables;
-- 
1.7.3.1

