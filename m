From: Wei Tang <tangwei@cmss.chinamobile.com>
Subject: [PATCH] net: the space is required after ','
Date: Thu, 16 Jun 2016 21:30:12 +0800
Message-ID: <1466083812-9793-1-git-send-email-tangwei@cmss.chinamobile.com>
Cc: ast@plumgrid.com, tom@herbertland.com, daniel@iogearbox.net,
	ja@ssi.bg, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Wei Tang <tangwei@cmss.chinamobile.com>
To: davem@davemloft.net, edumazet@google.com, aduyck@mirantis.com,
	jiri@mellanox.com, jarod@redhat.com, nikolay@cumulusnetworks.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The space is missing after ',', and this will introduce much more
noise when checking patch around.

Signed-off-by: Wei Tang <tangwei@cmss.chinamobile.com>
---
 net/core/dev.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 7a3fe58..a01511b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5919,7 +5919,7 @@ static void netdev_adjacent_add_links(struct net_device *dev)
 	struct net *net = dev_net(dev);
 
 	list_for_each_entry(iter, &dev->adj_list.upper, list) {
-		if (!net_eq(net,dev_net(iter->dev)))
+		if (!net_eq(net, dev_net(iter->dev)))
 			continue;
 		netdev_adjacent_sysfs_add(iter->dev, dev,
 					  &iter->dev->adj_list.lower);
@@ -5928,7 +5928,7 @@ static void netdev_adjacent_add_links(struct net_device *dev)
 	}
 
 	list_for_each_entry(iter, &dev->adj_list.lower, list) {
-		if (!net_eq(net,dev_net(iter->dev)))
+		if (!net_eq(net, dev_net(iter->dev)))
 			continue;
 		netdev_adjacent_sysfs_add(iter->dev, dev,
 					  &iter->dev->adj_list.upper);
@@ -5944,7 +5944,7 @@ static void netdev_adjacent_del_links(struct net_device *dev)
 	struct net *net = dev_net(dev);
 
 	list_for_each_entry(iter, &dev->adj_list.upper, list) {
-		if (!net_eq(net,dev_net(iter->dev)))
+		if (!net_eq(net, dev_net(iter->dev)))
 			continue;
 		netdev_adjacent_sysfs_del(iter->dev, dev->name,
 					  &iter->dev->adj_list.lower);
@@ -5953,7 +5953,7 @@ static void netdev_adjacent_del_links(struct net_device *dev)
 	}
 
 	list_for_each_entry(iter, &dev->adj_list.lower, list) {
-		if (!net_eq(net,dev_net(iter->dev)))
+		if (!net_eq(net, dev_net(iter->dev)))
 			continue;
 		netdev_adjacent_sysfs_del(iter->dev, dev->name,
 					  &iter->dev->adj_list.upper);
@@ -5969,7 +5969,7 @@ void netdev_adjacent_rename_links(struct net_device *dev, char *oldname)
 	struct net *net = dev_net(dev);
 
 	list_for_each_entry(iter, &dev->adj_list.upper, list) {
-		if (!net_eq(net,dev_net(iter->dev)))
+		if (!net_eq(net, dev_net(iter->dev)))
 			continue;
 		netdev_adjacent_sysfs_del(iter->dev, oldname,
 					  &iter->dev->adj_list.lower);
@@ -5978,7 +5978,7 @@ void netdev_adjacent_rename_links(struct net_device *dev, char *oldname)
 	}
 
 	list_for_each_entry(iter, &dev->adj_list.lower, list) {
-		if (!net_eq(net,dev_net(iter->dev)))
+		if (!net_eq(net, dev_net(iter->dev)))
 			continue;
 		netdev_adjacent_sysfs_del(iter->dev, oldname,
 					  &iter->dev->adj_list.upper);
-- 
1.9.1
