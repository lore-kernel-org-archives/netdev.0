From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] ipv6: remove unused function ipv6_inherit_linklocal()
Date: Fri,  2 May 2014 17:21:01 -0700
Message-ID: <1399076461-12172-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33650 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751366AbaECAVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2014 20:21:07 -0400
Received: by mail-pa0-f53.google.com with SMTP id kp14so1738438pab.12
        for <netdev@vger.kernel.org>; Fri, 02 May 2014 17:21:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is no longer used after commit e837735ec406a347756e
(ip6_tunnel: ensure to always have a link local address).

Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv6/addrconf.c | 12 ------------
 1 file changed, 12 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index fc203db..1ac13c0 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2818,18 +2818,6 @@ static void addrconf_gre_config(struct net_device *dev)
 }
 #endif
 
-static inline int
-ipv6_inherit_linklocal(struct inet6_dev *idev, struct net_device *link_dev)
-{
-	struct in6_addr lladdr;
-
-	if (!ipv6_get_lladdr(link_dev, &lladdr, IFA_F_TENTATIVE)) {
-		addrconf_add_linklocal(idev, &lladdr);
-		return 0;
-	}
-	return -1;
-}
-
 static int addrconf_notify(struct notifier_block *this, unsigned long event,
 			   void *ptr)
 {
-- 
1.8.3.1
