From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 4/5] bridge: Add missing policy entry for IFLA_BRPORT_FAST_LEAVE
Date: Wed, 26 Nov 2014 13:42:19 +0100
Message-ID: <d9840a68ab796c1826304f5f9a3b8f498ccba626.1417005245.git.tgraf@suug.ch>
References: <cover.1417005245.git.tgraf@suug.ch>
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:56911 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750884AbaKZMmd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 07:42:33 -0500
In-Reply-To: <cover.1417005245.git.tgraf@suug.ch>
In-Reply-To: <cover.1417005245.git.tgraf@suug.ch>
References: <cover.1417005245.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: c2d3babf ("bridge: implement multicast fast leave")
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/bridge/br_netlink.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 2ff9706..e5ec470 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -280,6 +280,7 @@ static const struct nla_policy br_port_policy[IFLA_BRPORT_MAX + 1] = {
 	[IFLA_BRPORT_MODE]	= { .type = NLA_U8 },
 	[IFLA_BRPORT_GUARD]	= { .type = NLA_U8 },
 	[IFLA_BRPORT_PROTECT]	= { .type = NLA_U8 },
+	[IFLA_BRPORT_FAST_LEAVE]= { .type = NLA_U8 },
 	[IFLA_BRPORT_LEARNING]	= { .type = NLA_U8 },
 	[IFLA_BRPORT_UNICAST_FLOOD] = { .type = NLA_U8 },
 };
-- 
1.9.3
