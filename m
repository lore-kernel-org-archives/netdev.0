From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 10/15] batman-adv: remove useless NULL check
Date: Mon, 14 Jan 2013 09:41:15 +1000
Message-ID: <1358120480-25960-11-git-send-email-ordex@autistici.org>
References: <1358120480-25960-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from diserzione.investici.org ([82.221.99.153]:49783 "EHLO
	diserzione.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755754Ab3AMXnI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2013 18:43:08 -0500
In-Reply-To: <1358120480-25960-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

debugfs_remove_recursive() checks whether its argument is not null
on its own, therefore it is possible to remove the external check.

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/debugfs.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/debugfs.c b/net/batman-adv/debugfs.c
index 0049837..5136d32 100644
--- a/net/batman-adv/debugfs.c
+++ b/net/batman-adv/debugfs.c
@@ -396,10 +396,8 @@ err:
 
 void batadv_debugfs_destroy(void)
 {
-	if (batadv_debugfs) {
-		debugfs_remove_recursive(batadv_debugfs);
-		batadv_debugfs = NULL;
-	}
+	debugfs_remove_recursive(batadv_debugfs);
+	batadv_debugfs = NULL;
 }
 
 int batadv_debugfs_add_meshif(struct net_device *dev)
-- 
1.8.0.2
