From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V3 2/3] net: Export gro_find_by_type helpers
Date: Wed,  8 Jan 2014 22:34:37 +0200
Message-ID: <1389213278-2200-3-git-send-email-ogerlitz@mellanox.com>
References: <1389213278-2200-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net, yanb@mellanox.com,
	shlomop@mellanox.com, Or Gerlitz <ogerlitz@mellanox.com>
To: hkchu@google.com, edumazet@google.com, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:43119 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757000AbaAHUeu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 15:34:50 -0500
In-Reply-To: <1389213278-2200-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Export the gro_find_receive/complete_by_type helpers to they can be invoked
by the gro callbacks of encapsulation protocols such as vxlan.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 net/core/dev.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 11f7acf..a052e54 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3936,6 +3936,7 @@ struct packet_offload *gro_find_receive_by_type(__be16 type)
 	}
 	return NULL;
 }
+EXPORT_SYMBOL(gro_find_receive_by_type);
 
 struct packet_offload *gro_find_complete_by_type(__be16 type)
 {
@@ -3949,6 +3950,7 @@ struct packet_offload *gro_find_complete_by_type(__be16 type)
 	}
 	return NULL;
 }
+EXPORT_SYMBOL(gro_find_complete_by_type);
 
 static gro_result_t napi_skb_finish(gro_result_t ret, struct sk_buff *skb)
 {
-- 
1.7.1
