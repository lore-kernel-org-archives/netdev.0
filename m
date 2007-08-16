From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 4/4] net: netdev_budget rearrangement
Date: Thu, 16 Aug 2007 09:25:27 -0400
Message-ID: <20070816132622.540107922@linux-foundation.org>
References: <20070816132523.201766718@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:50101 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758195AbXHPNfI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2007 09:35:08 -0400
Content-Disposition: inline; filename=netdev_budget.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Trivial patch, move netdev_budget declaration out of netdevice.h
to a new home with the other sysctl externs.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/include/linux/netdevice.h	2007-08-16 06:38:33.000000000 -0400
+++ b/include/linux/netdevice.h	2007-08-16 09:24:08.000000000 -0400
@@ -811,8 +811,6 @@ extern int		dev_hard_start_xmit(struct s
 					    struct net_device *dev);
 extern struct net_device_stats	*dev_get_stats(struct net_device *dev);
 
-extern int		netdev_budget;
-
 /* Called by rtnetlink.c:rtnl_unlock() */
 extern void netdev_run_todo(void);
 
--- a/net/core/sysctl_net_core.c	2007-08-06 04:26:48.000000000 -0400
+++ b/net/core/sysctl_net_core.c	2007-08-16 09:24:08.000000000 -0400
@@ -13,6 +13,7 @@
 
 #ifdef CONFIG_SYSCTL
 
+extern int netdev_budget;
 extern int netdev_max_backlog;
 extern int weight_p;
 

-- 

