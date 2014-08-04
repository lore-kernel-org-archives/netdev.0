From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] bridge: remove a useless comment
Date: Mon, 4 Aug 2014 15:22:40 +0200
Message-ID: <1407158554-17384-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, "David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

commit 6cbdceeb1cb12c7d620161925a8c3e81daadb2e4
    bridge: Dump vlan information from a bridge port
introduced a comment in an attempt to explain the
code logic. The comment is unfinished so it confuses more
than it explains, remove it.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 net/bridge/br_netlink.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 26edb51..cb5fcf6 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -208,7 +208,6 @@ int br_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 	int err = 0;
 	struct net_bridge_port *port = br_port_get_rtnl(dev);
 
-	/* not a bridge port and  */
 	if (!port && !(filter_mask & RTEXT_FILTER_BRVLAN))
 		goto out;
 
-- 
MST
