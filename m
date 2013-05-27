From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v9 02/11] vxlan: use unsigned int instead of unsigned
Date: Mon, 27 May 2013 12:16:24 +0800
Message-ID: <1369628193-14925-3-git-send-email-amwang@redhat.com>
References: <1369628193-14925-1-git-send-email-amwang@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21716 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750846Ab3E0ERG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 May 2013 00:17:06 -0400
In-Reply-To: <1369628193-14925-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

'unsigned int' is better.

Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 drivers/net/vxlan.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 0e3eca3..5b37f76 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1270,7 +1270,7 @@ static int vxlan_open(struct net_device *dev)
 /* Purge the forwarding table */
 static void vxlan_flush(struct vxlan_dev *vxlan)
 {
-	unsigned h;
+	unsigned int h;
 
 	spin_lock_bh(&vxlan->hash_lock);
 	for (h = 0; h < FDB_HASH_SIZE; ++h) {
@@ -1334,7 +1334,7 @@ static void vxlan_free(struct net_device *dev)
 static void vxlan_setup(struct net_device *dev)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
-	unsigned h;
+	unsigned int h;
 	int low, high;
 
 	eth_hw_addr_random(dev);
@@ -1460,7 +1460,7 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port)
 		.sin_addr.s_addr = htonl(INADDR_ANY),
 	};
 	int rc;
-	unsigned h;
+	unsigned int h;
 
 	vs = kmalloc(sizeof(*vs), GFP_KERNEL);
 	if (!vs)
@@ -1723,7 +1723,7 @@ static struct rtnl_link_ops vxlan_link_ops __read_mostly = {
 static __net_init int vxlan_init_net(struct net *net)
 {
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
-	unsigned h;
+	unsigned int h;
 
 	INIT_LIST_HEAD(&vn->vxlan_list);
 
-- 
1.7.7.6
