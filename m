From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] bonding: make release_and_destroy static
Date: Fri, 15 Oct 2010 08:09:34 -0700
Message-ID: <20101015080934.6dc28388@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34326 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755298Ab0JOPJg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Oct 2010 11:09:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only used in main file.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/bonding/bond_main.c	2010-10-15 08:07:14.163898236 -0700
+++ b/drivers/net/bonding/bond_main.c	2010-10-15 08:07:31.956373660 -0700
@@ -2057,8 +2057,8 @@ int bond_release(struct net_device *bond
 * First release a slave and than destroy the bond if no more slaves are left.
 * Must be under rtnl_lock when this function is called.
 */
-int  bond_release_and_destroy(struct net_device *bond_dev,
-			      struct net_device *slave_dev)
+static int  bond_release_and_destroy(struct net_device *bond_dev,
+				     struct net_device *slave_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	int ret;
--- a/drivers/net/bonding/bonding.h	2010-10-15 08:07:14.179898632 -0700
+++ b/drivers/net/bonding/bonding.h	2010-10-15 08:07:31.956373660 -0700
@@ -334,7 +334,6 @@ static inline void bond_unset_master_alb
 struct vlan_entry *bond_next_vlan(struct bonding *bond, struct vlan_entry *curr);
 int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_device *slave_dev);
 int bond_create(struct net *net, const char *name);
-int  bond_release_and_destroy(struct net_device *bond_dev, struct net_device *slave_dev);
 int bond_create_sysfs(void);
 void bond_destroy_sysfs(void);
 void bond_prepare_sysfs_group(struct bonding *bond);
