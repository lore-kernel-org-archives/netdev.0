From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/8] bonding: use net_device_ops
Date: Mon, 05 Jan 2009 12:14:44 -0800
Message-ID: <20090105201514.320689529@vyatta.com>
References: <20090105201442.749889072@vyatta.com>
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>, Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:35269 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752546AbZAEUYU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jan 2009 15:24:20 -0500
Content-Disposition: inline; filename=bonding-fix.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the correct pointer in debug message.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/bonding/bond_main.c	2009-01-01 22:44:01.785587952 -0800
+++ b/drivers/net/bonding/bond_main.c	2009-01-01 22:45:06.886088340 -0800
@@ -4148,7 +4148,7 @@ static int bond_change_mtu(struct net_de
 
 	bond_for_each_slave(bond, slave, i) {
 		pr_debug("s %p s->p %p c_m %p\n", slave,
-			slave->prev, slave->dev->change_mtu);
+			slave->prev, slave->dev->netdev_ops->ndo_change_mtu);
 
 		res = dev_set_mtu(slave->dev, new_mtu);
 

-- 

