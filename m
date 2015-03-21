From: sfeldma@gmail.com
Subject: [PATCH net-next] switchdev: kernel-doc cleanup on swithdev ops
Date: Fri, 20 Mar 2015 17:42:46 -0700
Message-ID: <1426898566-13974-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, ben@decadent.org.uk
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:36583 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752490AbbCUAlt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 20:41:49 -0400
Received: by pdbcz9 with SMTP id cz9so123290763pdb.3
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 17:41:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Suggested-by: Ben Hutchings <ben@decadent.org.uk>
Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/net/switchdev.h |   23 +++++++----------------
 1 file changed, 7 insertions(+), 16 deletions(-)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index e5de53f..d2e69ee 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -19,25 +19,16 @@ struct fib_info;
 /**
  * struct switchdev_ops - switchdev operations
  *
- * int (*swdev_parent_id_get)(struct net_device *dev,
- *			      struct netdev_phys_item_id *psid);
- *	Called to get an ID of the switch chip this port is part of.
- *	If driver implements this, it indicates that it represents a port
- *	of a switch chip.
+ * @swdev_parent_id_get: Called to get an ID of the switch chip this port
+ *   is part of.  If driver implements this, it indicates that it
+ *   represents a port of a switch chip.
  *
- * int (*swdev_port_stp_update)(struct net_device *dev, u8 state);
- *	Called to notify switch device port of bridge port STP
- *	state change.
+ * @swdev_port_stp_update: Called to notify switch device port of bridge
+ *   port STP state change.
  *
- * int (*swdev_fib_ipv4_add)(struct net_device *dev, __be32 dst,
- *			     int dst_len, struct fib_info *fi,
- *			     u8 tos, u8 type, u32 nlflags, u32 tb_id);
- *	Called to add/modify IPv4 route to switch device.
+ * @swdev_fib_ipv4_add: Called to add/modify IPv4 route to switch device.
  *
- * int (*swdev_fib_ipv4_del)(struct net_device *dev, __be32 dst,
- *			     int dst_len, struct fib_info *fi,
- *			     u8 tos, u8 type, u32 tb_id);
- *	Called to delete IPv4 route from switch device.
+ * @swdev_fib_ipv4_del: Called to delete IPv4 route from switch device.
  */
 struct swdev_ops {
 	int	(*swdev_parent_id_get)(struct net_device *dev,
-- 
1.7.10.4
