From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/4] net: cleanup left over decl
Date: Thu, 16 Aug 2007 09:25:24 -0400
Message-ID: <20070816132621.986860956@linux-foundation.org>
References: <20070816132523.201766718@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:57808 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757492AbXHPNez (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2007 09:34:55 -0400
Content-Disposition: inline; filename=dev_init.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove unneeded declaration.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/include/linux/netdevice.h	2007-08-15 14:29:02.000000000 +0100
+++ b/include/linux/netdevice.h	2007-08-15 14:35:25.000000000 +0100
@@ -833,8 +833,6 @@ extern int		dev_set_mac_address(struct n
 extern int		dev_hard_start_xmit(struct sk_buff *skb,
 					    struct net_device *dev);
 
-extern void		dev_init(void);
-
 extern int		netdev_budget;
 
 /* Called by rtnetlink.c:rtnl_unlock() */

-- 

