From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH] tipc endianness annotations
Date: Sun, 27 Apr 2008 06:40:21 +0100
Message-ID: <20080427054021.GS5882@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:54651 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752091AbYD0FkW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2008 01:40:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 net/tipc/msg.h |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 6ad070d..ad487e8 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -70,10 +70,9 @@ static inline void msg_set_bits(struct tipc_msg *m, u32 w,
 				u32 pos, u32 mask, u32 val)
 {
 	val = (val & mask) << pos;
-	val = htonl(val);
-	mask = htonl(mask << pos);
-	m->hdr[w] &= ~mask;
-	m->hdr[w] |= val;
+	mask = mask << pos;
+	m->hdr[w] &= ~htonl(mask);
+	m->hdr[w] |= htonl(val);
 }
 
 /*
-- 
1.5.3.GIT

