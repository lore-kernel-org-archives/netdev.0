From: Tan Xiaojun <tanxiaojun@huawei.com>
Subject: [PATCH net-next] bridge: spelling fixes
Date: Mon, 16 Dec 2013 21:32:46 +0800
Message-ID: <52AF00FE.4090607@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <bridge@lists.linux-foundation.org>, <netdev@vger.kernel.org>
To: <stephen@networkplumber.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:4887 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753655Ab3LPNdD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 08:33:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix spelling errors in bridge driver.

Signed-off-by: Tan Xiaojun <tanxiaojun@huawei.com>
---
 net/bridge/br_forward.c | 2 +-
 net/bridge/br_if.c      | 2 +-
 net/bridge/br_vlan.c    | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 4b81b14..96866aa 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -26,7 +26,7 @@ static int deliver_clone(const struct net_bridge_port *prev,
 			 void (*__packet_hook)(const struct net_bridge_port *p,
 					       struct sk_buff *skb));
 
-/* Don't forward packets to originating port or forwarding diasabled */
+/* Don't forward packets to originating port or forwarding disabled */
 static inline int should_deliver(const struct net_bridge_port *p,
 				 const struct sk_buff *skb)
 {
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 4bf02ad..1f6bd1e 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -61,7 +61,7 @@ static int port_cost(struct net_device *dev)
 }
 
 
-/* Check for port carrier transistions. */
+/* Check for port carrier transitions. */
 void br_port_carrier_check(struct net_bridge_port *p)
 {
 	struct net_device *dev = p->dev;
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index af5ebd1..7ffc801 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -146,7 +146,7 @@ struct sk_buff *br_handle_vlan(struct net_bridge *br,
 
 	/* At this point, we know that the frame was filtered and contains
 	 * a valid vlan id.  If the vlan id is set in the untagged bitmap,
-	 * send untagged; otherwise, send taged.
+	 * send untagged; otherwise, send tagged.
 	 */
 	br_vlan_get_tag(skb, &vid);
 	if (test_bit(vid, pv->untagged_bitmap))
-- 
1.8.0


.
