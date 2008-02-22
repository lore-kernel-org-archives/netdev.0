From: "Stephens, Allan" <allan.stephens@windriver.com>
Subject: [PATCH 05/08] [TIPC]: Use correct bitmask when setting version in message
Date: Fri, 22 Feb 2008 11:59:23 -0800
Message-ID: <AF1602CB2550CE4381C0C75118A7856B0246C895@ala-mail02.corp.ad.wrs.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:37367 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932065AbYBVT71 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2008 14:59:27 -0500
Received: from ALA-MAIL03.corp.ad.wrs.com (ala-mail03 [147.11.57.144])
	by mail.wrs.com (8.13.6/8.13.6) with ESMTP id m1MJxOnc017774
	for <netdev@vger.kernel.org>; Fri, 22 Feb 2008 11:59:25 -0800 (PST)
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch ensures that the 3-bit version field of the TIPC
message header is masked correctly when written into a message.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/msg.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 282e916..45c85a2 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -85,7 +85,7 @@ static inline u32 msg_version(struct tipc_msg *m)
 
 static inline void msg_set_version(struct tipc_msg *m)
 {
-	msg_set_bits(m, 0, 29, 0xf, TIPC_VERSION);
+	msg_set_bits(m, 0, 29, 0x7, TIPC_VERSION);
 }
 
 static inline u32 msg_user(struct tipc_msg *m)
-- 
1.5.3.2
