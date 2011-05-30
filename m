From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 16/17] batman-adv: a multiline comment should precede the variable it is describing
Date: Mon, 30 May 2011 09:23:01 +0200
Message-ID: <1306740182-2665-17-git-send-email-sven@narfation.org>
References: <1306740182-2665-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Sven Eckelmann <sven@narfation.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:60278 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755279Ab1E3HXY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 May 2011 03:23:24 -0400
In-Reply-To: <1306740182-2665-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>

This comment has been wrongly put after the variable it refers to and was also bad indented

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Acked-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
---
 net/batman-adv/types.h |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index fab70e8..65b3222 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -246,10 +246,10 @@ struct frag_packet_list_entry {
 };
 
 struct vis_info {
-	unsigned long       first_seen;
-	struct list_head    recv_list;
-			    /* list of server-neighbors we received a vis-packet
-			     * from.  we should not reply to them. */
+	unsigned long first_seen;
+	/* list of server-neighbors we received a vis-packet
+	 * from.  we should not reply to them. */
+	struct list_head recv_list;
 	struct list_head send_list;
 	struct kref refcount;
 	struct hlist_node hash_entry;
-- 
1.7.5.3

