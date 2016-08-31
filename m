From: fgao@ikuai8.com
Subject: [PATCH net-next] rps: flow_dissector: Add the const for the parameter of flow_keys_have_l4
Date: Wed, 31 Aug 2016 11:16:22 +0800
Message-ID: <1472613382-24322-1-git-send-email-fgao@ikuai8.com>
Cc: gfree.wind@gmail.com, Gao Feng <fgao@ikuai8.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg278.qq.com ([113.108.11.203]:48506 "EHLO smtpbg278.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754446AbcHaDQz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 30 Aug 2016 23:16:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

Add the const for the parameter of flow_keys_have_l4 for the readability.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 include/net/flow_dissector.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index f266b51..d953492 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -183,7 +183,7 @@ struct flow_keys_digest {
 void make_flow_keys_digest(struct flow_keys_digest *digest,
 			   const struct flow_keys *flow);
 
-static inline bool flow_keys_have_l4(struct flow_keys *keys)
+static inline bool flow_keys_have_l4(const struct flow_keys *keys)
 {
 	return (keys->ports.ports || keys->tags.flow_label);
 }
-- 
1.9.1
