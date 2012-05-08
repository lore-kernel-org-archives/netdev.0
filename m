From: pablo@netfilter.org
Subject: [PATCH 05/25] ipvs: timeout tables do not need GFP_ATOMIC allocation
Date: Tue,  8 May 2012 02:21:59 +0200
Message-ID: <1336436539-5880-6-git-send-email-pablo@netfilter.org>
References: <1336436539-5880-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51748 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758001Ab2EHAWy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2012 20:22:54 -0400
In-Reply-To: <1336436539-5880-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>

	They are called only on initialization.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_proto.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index 6eda11d..a981b7c 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -196,7 +196,7 @@ void ip_vs_protocol_timeout_change(struct netns_ipvs *ipvs, int flags)
 int *
 ip_vs_create_timeout_table(int *table, int size)
 {
-	return kmemdup(table, size, GFP_ATOMIC);
+	return kmemdup(table, size, GFP_KERNEL);
 }
 
 
-- 
1.7.9.5
