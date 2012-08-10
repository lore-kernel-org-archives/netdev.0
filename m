From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 11/15] vlan: clean up some variable names
Date: Fri, 10 Aug 2012 19:24:47 +0800
Message-ID: <1344597891-32242-12-git-send-email-amwang@redhat.com>
References: <1344597891-32242-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>, Benjamin LaHaise <bcrl@kvack.org>,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60156 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754906Ab2HJLZw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2012 07:25:52 -0400
In-Reply-To: <1344597891-32242-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To be consistent, s/info/vlan/.

Cc: Benjamin LaHaise <bcrl@kvack.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: David Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/8021q/vlan_dev.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index b65623f..0347d48 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -672,8 +672,8 @@ static void vlan_dev_poll_controller(struct net_device *dev)
 static int vlan_dev_netpoll_setup(struct net_device *dev, struct netpoll_info *npinfo,
 				  gfp_t gfp)
 {
-	struct vlan_dev_priv *info = vlan_dev_priv(dev);
-	struct net_device *real_dev = info->real_dev;
+	struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
+	struct net_device *real_dev = vlan->real_dev;
 	struct netpoll *netpoll;
 	int err = 0;
 
@@ -688,7 +688,7 @@ static int vlan_dev_netpoll_setup(struct net_device *dev, struct netpoll_info *n
 		goto out;
 	}
 
-	info->netpoll = netpoll;
+	vlan->netpoll = netpoll;
 
 out:
 	return err;
@@ -696,13 +696,13 @@ out:
 
 static void vlan_dev_netpoll_cleanup(struct net_device *dev)
 {
-	struct vlan_dev_priv *info = vlan_dev_priv(dev);
-	struct netpoll *netpoll = info->netpoll;
+	struct vlan_dev_priv *vlan= vlan_dev_priv(dev);
+	struct netpoll *netpoll = vlan->netpoll;
 
 	if (!netpoll)
 		return;
 
-	info->netpoll = NULL;
+	vlan->netpoll = NULL;
 
 	__netpoll_free_rcu(netpoll);
 }
-- 
1.7.7.6
