From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next] rtnetlink: Mark name argument of rtnl_create_link() const
Date: Fri, 10 Apr 2015 01:45:53 +0200
Message-ID: <0026a8339671614050a06eed45835946a3c74386.1428623089.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:58246 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753730AbbDIXpz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 19:45:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/net/rtnetlink.h | 2 +-
 net/core/rtnetlink.c    | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index 6c6d539..343d922 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -137,7 +137,7 @@ void rtnl_af_register(struct rtnl_af_ops *ops);
 void rtnl_af_unregister(struct rtnl_af_ops *ops);
 
 struct net *rtnl_link_get_net(struct net *src_net, struct nlattr *tb[]);
-struct net_device *rtnl_create_link(struct net *net, char *ifname,
+struct net_device *rtnl_create_link(struct net *net, const char *ifname,
 				    unsigned char name_assign_type,
 				    const struct rtnl_link_ops *ops,
 				    struct nlattr *tb[]);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index c3bf190..7a83615 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1932,7 +1932,7 @@ int rtnl_configure_link(struct net_device *dev, const struct ifinfomsg *ifm)
 EXPORT_SYMBOL(rtnl_configure_link);
 
 struct net_device *rtnl_create_link(struct net *net,
-	char *ifname, unsigned char name_assign_type,
+	const char *ifname, unsigned char name_assign_type,
 	const struct rtnl_link_ops *ops, struct nlattr *tb[])
 {
 	int err;
-- 
1.9.3
