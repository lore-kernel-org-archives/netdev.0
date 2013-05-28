From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next 2/3] vxlan: use unsigned int instead of unsigned
Date: Tue, 28 May 2013 16:35:52 +0800
Message-ID: <1369730153-11214-2-git-send-email-amwang@redhat.com>
References: <1369730153-11214-1-git-send-email-amwang@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53460 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933444Ab3E1IgJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 May 2013 04:36:09 -0400
In-Reply-To: <1369730153-11214-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

'unsigned int' is slightly better.

Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 drivers/net/vxlan.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 289d79a..6fc9620 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1269,7 +1269,7 @@ static int vxlan_open(struct net_device *dev)
 /* Purge the forwarding table */
 static void vxlan_flush(struct vxlan_dev *vxlan)
 {
-	unsigned h;
+	unsigned int h;
 
 	spin_lock_bh(&vxlan->hash_lock);
 	for (h = 0; h < FDB_HASH_SIZE; ++h) {
@@ -1333,7 +1333,7 @@ static void vxlan_free(struct net_device *dev)
 static void vxlan_setup(struct net_device *dev)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
-	unsigned h;
+	unsigned int h;
 	int low, high;
 
 	eth_hw_addr_random(dev);
@@ -1459,7 +1459,7 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port)
 		.sin_addr.s_addr = htonl(INADDR_ANY),
 	};
 	int rc;
-	unsigned h;
+	unsigned int h;
 
 	vs = kmalloc(sizeof(*vs), GFP_KERNEL);
 	if (!vs)
@@ -1722,7 +1722,7 @@ static struct rtnl_link_ops vxlan_link_ops __read_mostly = {
 static __net_init int vxlan_init_net(struct net *net)
 {
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
-	unsigned h;
+	unsigned int h;
 
 	INIT_LIST_HEAD(&vn->vxlan_list);
 
-- 
1.7.7.6
