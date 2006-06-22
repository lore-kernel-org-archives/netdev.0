From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 11/32] [TIPC] Fix misleading comment in buf_discard() routine.
Date: Thu, 22 Jun 2006 15:59:24 +0200
Message-ID: <11509847862546-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw4.ericsson.se ([193.180.251.62]:34966 "EHLO
	mailgw4.ericsson.se") by vger.kernel.org with ESMTP
	id S1030648AbWFVN7v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 09:59:51 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/core.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/tipc/core.h b/net/tipc/core.h
index d1edb7a..86f54f3 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -318,7 +318,7 @@ static inline struct sk_buff *buf_acquir
  * buf_discard - frees a TIPC message buffer
  * @skb: message buffer
  *
- * Frees a new buffer.  If passed NULL, just returns.
+ * Frees a message buffer.  If passed NULL, just returns.
  */
 
 static inline void buf_discard(struct sk_buff *skb)
-- 
1.4.0

