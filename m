From: kaber@trash.net
Subject: [PATCH 02/72] netfilter: use NFPROTO_IPV4 instead of AF_INET
Date: Thu, 21 Oct 2010 17:18:49 +0200
Message-ID: <1287674399-31455-3-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59983 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752053Ab0JUPUC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 11:20:02 -0400
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>

The field family of xt_target should be NFPROTO_IPV4, though
NFPROTO_IPV4 and AF_INET are the same.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/xt_TPROXY.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index c61294d..21bb2af 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -76,7 +76,7 @@ static int tproxy_tg_check(const struct xt_tgchk_param *par)
 
 static struct xt_target tproxy_tg_reg __read_mostly = {
 	.name		= "TPROXY",
-	.family		= AF_INET,
+	.family		= NFPROTO_IPV4,
 	.table		= "mangle",
 	.target		= tproxy_tg,
 	.targetsize	= sizeof(struct xt_tproxy_target_info),
-- 
1.7.1

