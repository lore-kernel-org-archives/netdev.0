From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 15/15] batman-adv: beautify supported routing algorithm list
Date: Tue, 25 Aug 2015 13:02:39 +0200
Message-ID: <1440500559-28368-16-git-send-email-antonio__20208.8681552143$1440501802$gmane$org@meshcoding.com>
References: <1440500559-28368-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:3143 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751691AbbHYLXH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2015 07:23:07 -0400
In-Reply-To: <1440500559-28368-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <mareklindner@neomailbox.ch>

Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 50fc07b..e61c5f3 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -584,7 +584,7 @@ int batadv_algo_seq_print_text(struct seq_file *seq, void *offset)
 	seq_puts(seq, "Available routing algorithms:\n");
 
 	hlist_for_each_entry(bat_algo_ops, &batadv_algo_list, list) {
-		seq_printf(seq, "%s\n", bat_algo_ops->name);
+		seq_printf(seq, " * %s\n", bat_algo_ops->name);
 	}
 
 	return 0;
-- 
2.5.0
