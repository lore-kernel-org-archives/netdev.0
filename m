From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] tipc: trivial endian annotation in debug statement
Date: Fri, 07 Nov 2008 17:12:07 -0800
Message-ID: <1226106727.11596.59.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.234]:13862 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750903AbYKHBMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 20:12:10 -0500
Received: by rv-out-0506.google.com with SMTP id k40so1544946rvb.1
        for <netdev@vger.kernel.org>; Fri, 07 Nov 2008 17:12:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use htonl rather than ntohl on a u32.
net/tipc/name_table.c:557:2: warning: cast to restricted __be32

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 net/tipc/name_table.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index cd72e22..acab41a 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -555,7 +555,7 @@ static struct name_seq *nametbl_find_seq(u32 type)
 	struct name_seq *ns;
 
 	dbg("find_seq %u,(%u,0x%x) table = %p, hash[type] = %u\n",
-	    type, ntohl(type), type, table.types, hash(type));
+	    type, htonl(type), type, table.types, hash(type));
 
 	seq_head = &table.types[hash(type)];
 	hlist_for_each_entry(ns, seq_node, seq_head, ns_list) {
-- 
1.6.0.3.756.gb776d



