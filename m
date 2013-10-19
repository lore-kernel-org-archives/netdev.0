From: David Miller <davem@davemloft.net>
Subject: [PATCH] bonding: Remove __exit tag from bond_netlink_fini().
Date: Sat, 19 Oct 2013 19:10:11 -0400 (EDT)
Message-ID: <20131019.191011.539854819275656137.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40402 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750896Ab3JSXKT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 19:10:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It can be called from the module init function, so it cannot
be in the exit section.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/bonding/bond_netlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index fe3500b..7661261 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -123,7 +123,7 @@ int __init bond_netlink_init(void)
 	return rtnl_link_register(&bond_link_ops);
 }
 
-void __exit bond_netlink_fini(void)
+void bond_netlink_fini(void)
 {
 	rtnl_link_unregister(&bond_link_ops);
 }
-- 
1.7.11.7
