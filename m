From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 1/3] batman-adv: add blank line between declarations and the rest of the code
Date: Sun, 18 May 2014 19:58:08 +0200
Message-ID: <1400435890-6667-2-git-send-email-antonio@meshcoding.com>
References: <1400435890-6667-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@meshcoding.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:26249 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750864AbaERR7d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 May 2014 13:59:33 -0400
In-Reply-To: <1400435890-6667-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported by checkpatch with the following message:
"WARNING: Missing a blank line after declarations"

Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/debugfs.c               |  9 +++++++++
 net/batman-adv/distributed-arp-table.c |  1 +
 net/batman-adv/network-coding.c        |  1 +
 net/batman-adv/sysfs.c                 | 10 ++++++++++
 4 files changed, 21 insertions(+)

diff --git a/net/batman-adv/debugfs.c b/net/batman-adv/debugfs.c
index b758881..99f2ba0 100644
--- a/net/batman-adv/debugfs.c
+++ b/net/batman-adv/debugfs.c
@@ -245,6 +245,7 @@ static int batadv_algorithms_open(struct inode *inode, struct file *file)
 static int batadv_originators_open(struct inode *inode, struct file *file)
 {
 	struct net_device *net_dev = (struct net_device *)inode->i_private;
+
 	return single_open(file, batadv_orig_seq_print_text, net_dev);
 }
 
@@ -258,18 +259,21 @@ static int batadv_originators_hardif_open(struct inode *inode,
 					  struct file *file)
 {
 	struct net_device *net_dev = (struct net_device *)inode->i_private;
+
 	return single_open(file, batadv_orig_hardif_seq_print_text, net_dev);
 }
 
 static int batadv_gateways_open(struct inode *inode, struct file *file)
 {
 	struct net_device *net_dev = (struct net_device *)inode->i_private;
+
 	return single_open(file, batadv_gw_client_seq_print_text, net_dev);
 }
 
 static int batadv_transtable_global_open(struct inode *inode, struct file *file)
 {
 	struct net_device *net_dev = (struct net_device *)inode->i_private;
+
 	return single_open(file, batadv_tt_global_seq_print_text, net_dev);
 }
 
@@ -277,6 +281,7 @@ static int batadv_transtable_global_open(struct inode *inode, struct file *file)
 static int batadv_bla_claim_table_open(struct inode *inode, struct file *file)
 {
 	struct net_device *net_dev = (struct net_device *)inode->i_private;
+
 	return single_open(file, batadv_bla_claim_table_seq_print_text,
 			   net_dev);
 }
@@ -285,6 +290,7 @@ static int batadv_bla_backbone_table_open(struct inode *inode,
 					  struct file *file)
 {
 	struct net_device *net_dev = (struct net_device *)inode->i_private;
+
 	return single_open(file, batadv_bla_backbone_table_seq_print_text,
 			   net_dev);
 }
@@ -300,6 +306,7 @@ static int batadv_bla_backbone_table_open(struct inode *inode,
 static int batadv_dat_cache_open(struct inode *inode, struct file *file)
 {
 	struct net_device *net_dev = (struct net_device *)inode->i_private;
+
 	return single_open(file, batadv_dat_cache_seq_print_text, net_dev);
 }
 #endif
@@ -307,6 +314,7 @@ static int batadv_dat_cache_open(struct inode *inode, struct file *file)
 static int batadv_transtable_local_open(struct inode *inode, struct file *file)
 {
 	struct net_device *net_dev = (struct net_device *)inode->i_private;
+
 	return single_open(file, batadv_tt_local_seq_print_text, net_dev);
 }
 
@@ -319,6 +327,7 @@ struct batadv_debuginfo {
 static int batadv_nc_nodes_open(struct inode *inode, struct file *file)
 {
 	struct net_device *net_dev = (struct net_device *)inode->i_private;
+
 	return single_open(file, batadv_nc_nodes_seq_print_text, net_dev);
 }
 #endif
diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index b25fd64..60889df 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -662,6 +662,7 @@ static void batadv_dat_tvlv_container_update(struct batadv_priv *bat_priv)
 void batadv_dat_status_update(struct net_device *net_dev)
 {
 	struct batadv_priv *bat_priv = netdev_priv(net_dev);
+
 	batadv_dat_tvlv_container_update(bat_priv);
 }
 
diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index a9546fe..40a2fc4 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -86,6 +86,7 @@ static void batadv_nc_tvlv_container_update(struct batadv_priv *bat_priv)
 void batadv_nc_status_update(struct net_device *net_dev)
 {
 	struct batadv_priv *bat_priv = netdev_priv(net_dev);
+
 	batadv_nc_tvlv_container_update(bat_priv);
 }
 
diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index 1ebb0d9..f51b484 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -29,12 +29,14 @@
 static struct net_device *batadv_kobj_to_netdev(struct kobject *obj)
 {
 	struct device *dev = container_of(obj->parent, struct device, kobj);
+
 	return to_net_dev(dev);
 }
 
 static struct batadv_priv *batadv_kobj_to_batpriv(struct kobject *obj)
 {
 	struct net_device *net_dev = batadv_kobj_to_netdev(obj);
+
 	return netdev_priv(net_dev);
 }
 
@@ -124,6 +126,7 @@ ssize_t batadv_store_##_name(struct kobject *kobj,			\
 {									\
 	struct net_device *net_dev = batadv_kobj_to_netdev(kobj);	\
 	struct batadv_priv *bat_priv = netdev_priv(net_dev);		\
+									\
 	return __batadv_store_bool_attr(buff, count, _post_func, attr,	\
 					&bat_priv->_name, net_dev);	\
 }
@@ -133,6 +136,7 @@ ssize_t batadv_show_##_name(struct kobject *kobj,			\
 			    struct attribute *attr, char *buff)		\
 {									\
 	struct batadv_priv *bat_priv = batadv_kobj_to_batpriv(kobj);	\
+									\
 	return sprintf(buff, "%s\n",					\
 		       atomic_read(&bat_priv->_name) == 0 ?		\
 		       "disabled" : "enabled");				\
@@ -155,6 +159,7 @@ ssize_t batadv_store_##_name(struct kobject *kobj,			\
 {									\
 	struct net_device *net_dev = batadv_kobj_to_netdev(kobj);	\
 	struct batadv_priv *bat_priv = netdev_priv(net_dev);		\
+									\
 	return __batadv_store_uint_attr(buff, count, _min, _max,	\
 					_post_func, attr,		\
 					&bat_priv->_name, net_dev);	\
@@ -165,6 +170,7 @@ ssize_t batadv_show_##_name(struct kobject *kobj,			\
 			    struct attribute *attr, char *buff)		\
 {									\
 	struct batadv_priv *bat_priv = batadv_kobj_to_batpriv(kobj);	\
+									\
 	return sprintf(buff, "%i\n", atomic_read(&bat_priv->_name));	\
 }									\
 
@@ -188,6 +194,7 @@ ssize_t batadv_store_vlan_##_name(struct kobject *kobj,			\
 	size_t res = __batadv_store_bool_attr(buff, count, _post_func,	\
 					      attr, &vlan->_name,	\
 					      bat_priv->soft_iface);	\
+									\
 	batadv_softif_vlan_free_ref(vlan);				\
 	return res;							\
 }
@@ -202,6 +209,7 @@ ssize_t batadv_show_vlan_##_name(struct kobject *kobj,			\
 	size_t res = sprintf(buff, "%s\n",				\
 			     atomic_read(&vlan->_name) == 0 ?		\
 			     "disabled" : "enabled");			\
+									\
 	batadv_softif_vlan_free_ref(vlan);				\
 	return res;							\
 }
@@ -324,12 +332,14 @@ static ssize_t batadv_show_bat_algo(struct kobject *kobj,
 				    struct attribute *attr, char *buff)
 {
 	struct batadv_priv *bat_priv = batadv_kobj_to_batpriv(kobj);
+
 	return sprintf(buff, "%s\n", bat_priv->bat_algo_ops->name);
 }
 
 static void batadv_post_gw_reselect(struct net_device *net_dev)
 {
 	struct batadv_priv *bat_priv = netdev_priv(net_dev);
+
 	batadv_gw_reselect(bat_priv);
 }
 
-- 
1.8.5.5
