From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 2/3] net/sched: cls_flower: Remove an unsed field from the filter key structure
Date: Tue, 13 Sep 2016 17:02:40 +0300
Message-ID: <1473775361-16547-3-git-send-email-ogerlitz@mellanox.com>
References: <1473775361-16547-1-git-send-email-ogerlitz@mellanox.com>
Cc: Jiri Pirko <jiri@mellanox.com>, netdev@vger.kernel.org,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:36268 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751567AbcIMOCx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 10:02:53 -0400
In-Reply-To: <1473775361-16547-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit c3f8324188fa "net: Add full IPv6 addresses to flow_keys" added an
unsed instance of struct flow_dissector_key_addrs into struct fl_flow_key,
remove it.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reported-by: Hadar Hen Zion <hadarh@mellanox.com>
---
 net/sched/cls_flower.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 027523c..a3f4c70 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -33,7 +33,6 @@ struct fl_flow_key {
 	struct flow_dissector_key_basic basic;
 	struct flow_dissector_key_eth_addrs eth;
 	struct flow_dissector_key_vlan vlan;
-	struct flow_dissector_key_addrs ipaddrs;
 	union {
 		struct flow_dissector_key_ipv4_addrs ipv4;
 		struct flow_dissector_key_ipv6_addrs ipv6;
-- 
2.3.7
