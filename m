From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 06/28] tipc: Update obsolete references to multicast link
Date: Sat, 17 Sep 2011 23:32:02 -0400
Message-ID: <1316316744-29514-7-git-send-email-paul.gortmaker@windriver.com>
References: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49967 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753272Ab1IRDco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 23:32:44 -0400
In-Reply-To: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Updates TIPC's broadcast link in a couple of places that were missed
during the transition from its former name ("multicast-link") to its
current name ("broadcast-link"). These changes are essentially cosmetic
and do not affect the overall operation of TIPC.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 759b318..411c54b 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -764,7 +764,7 @@ int tipc_bclink_init(void)
 	bcbearer = kzalloc(sizeof(*bcbearer), GFP_ATOMIC);
 	bclink = kzalloc(sizeof(*bclink), GFP_ATOMIC);
 	if (!bcbearer || !bclink) {
-		warn("Multicast link creation failed, no memory\n");
+		warn("Broadcast link creation failed, no memory\n");
 		kfree(bcbearer);
 		bcbearer = NULL;
 		kfree(bclink);
@@ -775,7 +775,7 @@ int tipc_bclink_init(void)
 	INIT_LIST_HEAD(&bcbearer->bearer.cong_links);
 	bcbearer->bearer.media = &bcbearer->media;
 	bcbearer->media.send_msg = tipc_bcbearer_send;
-	sprintf(bcbearer->media.name, "tipc-multicast");
+	sprintf(bcbearer->media.name, "tipc-broadcast");
 
 	bcl = &bclink->link;
 	INIT_LIST_HEAD(&bcl->waiting_ports);
-- 
1.7.4.4
