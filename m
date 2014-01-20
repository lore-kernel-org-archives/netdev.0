From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V5 net-next 2/3] net: Export gro_find_by_type helpers
Date: Mon, 20 Jan 2014 13:59:20 +0200
Message-ID: <1390219161-9881-3-git-send-email-ogerlitz@mellanox.com>
References: <1390219161-9881-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, hkchu@google.com, edumazet@google.com,
	herbert@gondor.apana.org.au, yanb@mellanox.com,
	shlomop@mellanox.com, therbert@google.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:34345 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750822AbaATL7a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jan 2014 06:59:30 -0500
In-Reply-To: <1390219161-9881-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Export the gro_find_receive/complete_by_type helpers to they can be invoked
by the gro callbacks of encapsulation protocols such as vxlan.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 net/core/dev.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 1578fd7..ed8af53 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3984,6 +3984,7 @@ struct packet_offload *gro_find_receive_by_type(__be16 type)
 	}
 	return NULL;
 }
+EXPORT_SYMBOL(gro_find_receive_by_type);
 
 struct packet_offload *gro_find_complete_by_type(__be16 type)
 {
@@ -3997,6 +3998,7 @@ struct packet_offload *gro_find_complete_by_type(__be16 type)
 	}
 	return NULL;
 }
+EXPORT_SYMBOL(gro_find_complete_by_type);
 
 static gro_result_t napi_skb_finish(gro_result_t ret, struct sk_buff *skb)
 {
-- 
1.7.1
