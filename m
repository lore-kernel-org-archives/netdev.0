From: Tan Xiaojun <tanxiaojun@huawei.com>
Subject: [PATCH 2/5] bridge: remove unnecessary parentheses
Date: Thu, 19 Dec 2013 13:28:11 +0800
Message-ID: <1387430894-11220-3-git-send-email-tanxiaojun@huawei.com>
References: <1387430894-11220-1-git-send-email-tanxiaojun@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <bridge@lists.linux-foundation.org>, <netdev@vger.kernel.org>
To: <stephen@networkplumber.org>, <davem@davemloft.net>,
	<bart.de.schuymer@pandora.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:44501 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750807Ab3LSF2o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 00:28:44 -0500
In-Reply-To: <1387430894-11220-1-git-send-email-tanxiaojun@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Return is not a function, parentheses are not required.

Signed-off-by: Tan Xiaojun <tanxiaojun@huawei.com>
---
 net/bridge/br_forward.c         | 4 ++--
 net/bridge/netfilter/ebtables.c | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 96866aa..d3409e6 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -30,9 +30,9 @@ static int deliver_clone(const struct net_bridge_port *prev,
 static inline int should_deliver(const struct net_bridge_port *p,
 				 const struct sk_buff *skb)
 {
-	return (((p->flags & BR_HAIRPIN_MODE) || skb->dev != p->dev) &&
+	return ((p->flags & BR_HAIRPIN_MODE) || skb->dev != p->dev) &&
 		br_allowed_egress(p->br, nbp_get_vlan_info(p), skb) &&
-		p->state == BR_STATE_FORWARDING);
+		p->state == BR_STATE_FORWARDING;
 }
 
 static inline unsigned int packet_length(const struct sk_buff *skb)
diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index ac78024..09d16d7 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -118,7 +118,7 @@ ebt_dev_check(const char *entry, const struct net_device *device)
 	/* 1 is the wildcard token */
 	while (entry[i] != '\0' && entry[i] != 1 && entry[i] == devname[i])
 		i++;
-	return (devname[i] != entry[i] && entry[i] != 1);
+	return devname[i] != entry[i] && entry[i] != 1;
 }
 
 #define FWINV2(bool,invflg) ((bool) ^ !!(e->invflags & invflg))
-- 
1.8.0
