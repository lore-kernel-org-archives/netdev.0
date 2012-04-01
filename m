From: Eldad Zack <eldad@fogrefinery.com>
Subject: [PATCH 1/8] net/ipv6/sit.c: Checkpatch cleanup
Date: Sun,  1 Apr 2012 19:49:01 +0200
Message-ID: <1333302548-9187-1-git-send-email-eldad@fogrefinery.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eldad Zack <eldad@fogrefinery.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

sit.c:118: ERROR: "foo * bar" should be "foo *bar"
sit.c:694: ERROR: "(foo*)" should be "(foo *)"
sit.c:724: ERROR: "(foo*)" should be "(foo *)"

Signed-off-by: Eldad Zack <eldad@fogrefinery.com>
---
 net/ipv6/sit.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index c4ffd17..f9608db 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -115,7 +115,7 @@ static struct net_device_stats *ipip6_get_stats(struct net_device *dev)
 /*
  * Must be invoked with rcu_read_lock
  */
-static struct ip_tunnel * ipip6_tunnel_lookup(struct net *net,
+static struct ip_tunnel *ipip6_tunnel_lookup(struct net *net,
 		struct net_device *dev, __be32 remote, __be32 local)
 {
 	unsigned int h0 = HASH(remote);
@@ -691,7 +691,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 			goto tx_error;
 		}
 
-		addr6 = (const struct in6_addr*)&neigh->primary_key;
+		addr6 = (const struct in6_addr *)&neigh->primary_key;
 		addr_type = ipv6_addr_type(addr6);
 
 		if ((addr_type & IPV6_ADDR_UNICAST) &&
@@ -721,7 +721,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 			goto tx_error;
 		}
 
-		addr6 = (const struct in6_addr*)&neigh->primary_key;
+		addr6 = (const struct in6_addr *)&neigh->primary_key;
 		addr_type = ipv6_addr_type(addr6);
 
 		if (addr_type == IPV6_ADDR_ANY) {
-- 
1.7.9.5
