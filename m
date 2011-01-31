From: kaber@trash.net
Subject: [PATCH 6/7] netfilter: xt_iprange: typo in IPv4 match debug print code
Date: Mon, 31 Jan 2011 21:10:19 +0100
Message-ID: <1296504620-820-7-git-send-email-kaber@trash.net>
References: <1296504620-820-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59946 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755976Ab1AaUKf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jan 2011 15:10:35 -0500
In-Reply-To: <1296504620-820-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Jacob <jacob@internet24.de>

Signed-off-by: Thomas Jacob <jacob@internet24.de>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/xt_iprange.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/xt_iprange.c b/net/netfilter/xt_iprange.c
index 88f7c35..77b9ebc 100644
--- a/net/netfilter/xt_iprange.c
+++ b/net/netfilter/xt_iprange.c
@@ -31,7 +31,7 @@ iprange_mt4(const struct sk_buff *skb, struct xt_action_param *par)
 			pr_debug("src IP %pI4 NOT in range %s%pI4-%pI4\n",
 			         &iph->saddr,
 			         (info->flags & IPRANGE_SRC_INV) ? "(INV) " : "",
-			         &info->src_max.ip,
+			         &info->src_min.ip,
 			         &info->src_max.ip);
 			return false;
 		}
-- 
1.7.2.3

