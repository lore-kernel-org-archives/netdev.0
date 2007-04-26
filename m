From: Jon Paul Maloy <jon.maloy@ericsson.com>
Subject: [PATCH] [TIPC]: Changed msg_set_bits params type
Date: Thu, 26 Apr 2007 15:57:55 -0400
Message-ID: <46310443.7090405@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	"Stephens, Allan" <allan.stephens@windriver.com>,
	Jon Paul Maloy <jon.maloy@donjonn.com>,
	Per Liden <per.liden@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imr2.ericy.com ([198.24.6.3]:58967 "EHLO imr2.ericy.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031359AbXDZT6B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 15:58:01 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To ease use of sparse, as requested by Ingo Oeser.

Signed-off-by: Jon Paul Maloy <jon.maloy@ericsson.com>
---
 net/tipc/msg.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 5c64e55..f9f3dd0 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -69,7 +69,7 @@ static inline void msg_set_word(struct tipc_msg *m, 
u32 w, u32 val)
 }

 static inline void msg_set_bits(struct tipc_msg *m, u32 w,
-                               u32 pos, u32 mask, u32 val)
+                               u32 pos, __be32 mask, __be32 val)
 {
        val = (val & mask) << pos;
        val = htonl(val);
--
1.5.0.5

///jon
