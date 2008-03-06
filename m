From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 5/7 net-2.6.26] [TIPC]: Use correct bitmask when setting version
Date: Thu,  6 Mar 2008 16:34:27 -0500
Message-ID: <1204839269-30593-6-git-send-email-allan.stephens@windriver.com>
References: <1204839269-30593-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:55394 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763838AbYCFVu3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Mar 2008 16:50:29 -0500
In-Reply-To: <1204839269-30593-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch ensures that the 3-bit version field of the TIPC
message header is masked correctly when written into a message.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/msg.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 5cf76a4..88a2ee0 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -85,7 +85,7 @@ static inline u32 msg_version(struct tipc_msg *m)
 
 static inline void msg_set_version(struct tipc_msg *m)
 {
-	msg_set_bits(m, 0, 29, 0xf, TIPC_VERSION);
+	msg_set_bits(m, 0, 29, 7, TIPC_VERSION);
 }
 
 static inline u32 msg_user(struct tipc_msg *m)
-- 
1.5.3.2

