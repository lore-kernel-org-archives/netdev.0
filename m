From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 5/5] rtnetlink: remove ndo_get_slave
Date: Wed, 22 Jan 2014 09:05:57 +0100
Message-ID: <1390377957-31466-6-git-send-email-jiri@resnulli.us>
References: <1390377957-31466-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, fubar@us.ibm.com, vfalico@redhat.com,
	andy@greyhouse.net, sfeldma@cumulusnetworks.com,
	stephen@networkplumber.org, vyasevic@redhat.com,
	nicolas.dichtel@6wind.com, john.r.fastabend@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:39861 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753002AbaAVIGN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 03:06:13 -0500
Received: by mail-ea0-f174.google.com with SMTP id b10so4308408eae.19
        for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 00:06:12 -0800 (PST)
In-Reply-To: <1390377957-31466-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No longer used API bond-specific can be removed now. This is now handled
in a generic way in rtnl_link_ops.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/netdevice.h | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 83ce2ae..e985231 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -921,9 +921,6 @@ struct netdev_phys_port_id {
  * int (*ndo_del_slave)(struct net_device *dev, struct net_device *slave_dev);
  *	Called to release previously enslaved netdev.
  *
- * int (*ndo_get_slave)(struct net_device *slave_dev, struct sk_buff *skb);
- *	Called to fill netlink skb with slave info.
- *
  *      Feature/offload setting functions.
  * netdev_features_t (*ndo_fix_features)(struct net_device *dev,
  *		netdev_features_t features);
@@ -1096,8 +1093,6 @@ struct net_device_ops {
 						 struct net_device *slave_dev);
 	int			(*ndo_del_slave)(struct net_device *dev,
 						 struct net_device *slave_dev);
-	int			(*ndo_get_slave)(struct net_device *slave_dev,
-						 struct sk_buff *skb);
 	netdev_features_t	(*ndo_fix_features)(struct net_device *dev,
 						    netdev_features_t features);
 	int			(*ndo_set_features)(struct net_device *dev,
-- 
1.8.3.1
