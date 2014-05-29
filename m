From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/3] netfilter: Fix format string mismatch in ip_vs_proto_name()
Date: Thu, 29 May 2014 17:54:58 +0200
Message-ID: <1401378900-12436-2-git-send-email-pablo@netfilter.org>
References: <1401378900-12436-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58793 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933523AbaE2PzL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2014 11:55:11 -0400
In-Reply-To: <1401378900-12436-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Masanari Iida <standby24x7@gmail.com>

Fix string mismatch in ip_vs_proto_name()

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipvs/ip_vs_core.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 4f26ee4..d9da8c4 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -97,7 +97,7 @@ const char *ip_vs_proto_name(unsigned int proto)
 		return "ICMPv6";
 #endif
 	default:
-		sprintf(buf, "IP_%d", proto);
+		sprintf(buf, "IP_%u", proto);
 		return buf;
 	}
 }
-- 
1.7.10.4
