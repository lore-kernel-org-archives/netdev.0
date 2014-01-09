From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 06/13] batman-adv: remove parenthesis from return statements
Date: Thu,  9 Jan 2014 15:52:55 +0100
Message-ID: <1389279182-3256-7-git-send-email-antonio@meshcoding.com>
References: <1389279182-3256-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@meshcoding.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:26836 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752338AbaAIOyr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 09:54:47 -0500
In-Reply-To: <1389279182-3256-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove parenthesis around return expression as suggested by
checkpatch.

Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/distributed-arp-table.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index 01ec607..93e1fb0 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -139,7 +139,7 @@ static int batadv_compare_dat(const struct hlist_node *node, const void *data2)
 	const void *data1 = container_of(node, struct batadv_dat_entry,
 					 hash_entry);
 
-	return (memcmp(data1, data2, sizeof(__be32)) == 0 ? 1 : 0);
+	return memcmp(data1, data2, sizeof(__be32)) == 0 ? 1 : 0;
 }
 
 /**
-- 
1.8.5.2
