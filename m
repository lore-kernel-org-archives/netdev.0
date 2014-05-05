From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net-next] tunnel: fix RFC number in comment for INET_ECN_decapsulate()
Date: Sun,  4 May 2014 20:55:39 -0400
Message-ID: <1399251339-17817-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f201.google.com ([209.85.128.201]:59461 "EHLO
	mail-ve0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753971AbaEEAzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2014 20:55:46 -0400
Received: by mail-ve0-f201.google.com with SMTP id db11so39204veb.0
        for <netdev@vger.kernel.org>; Sun, 04 May 2014 17:55:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The quoted text and figure are from RFC 6040 ("Tunnelling of Explicit
Congestion Notification").

Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 include/net/inet_ecn.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/inet_ecn.h b/include/net/inet_ecn.h
index 3bd2279..84b2083 100644
--- a/include/net/inet_ecn.h
+++ b/include/net/inet_ecn.h
@@ -150,7 +150,7 @@ static inline int INET_ECN_set_ce(struct sk_buff *skb)
 }
 
 /*
- * RFC 6080 4.2
+ * RFC 6040 4.2
  *  To decapsulate the inner header at the tunnel egress, a compliant
  *  tunnel egress MUST set the outgoing ECN field to the codepoint at the
  *  intersection of the appropriate arriving inner header (row) and outer
-- 
1.9.1.423.g4596e3a
