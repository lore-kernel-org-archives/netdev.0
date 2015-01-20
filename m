From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 2/6] ip6gretap: advertise link netns via netlink
Date: Tue, 20 Jan 2015 15:15:43 +0100
Message-ID: <1421763347-4354-3-git-send-email-nicolas.dichtel@6wind.com>
References: <1421763347-4354-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:53800 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751993AbbATOP5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 09:15:57 -0500
In-Reply-To: <1421763347-4354-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Assign rtnl_link_ops->get_link_net() callback so that IFLA_LINK_NETNSID is
added to rtnetlink messages.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/ip6_gre.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 9306a5ff9149..6dee2a8ca0a9 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -1676,6 +1676,7 @@ static struct rtnl_link_ops ip6gre_tap_ops __read_mostly = {
 	.changelink	= ip6gre_changelink,
 	.get_size	= ip6gre_get_size,
 	.fill_info	= ip6gre_fill_info,
+	.get_link_net	= ip6_tnl_get_link_net,
 };
 
 /*
-- 
2.2.2
