From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 12/12] batman-adv: Remove unnecessary ret variable in algo_register
Date: Wed,  3 Jun 2015 16:14:08 +0200
Message-ID: <1433340848-1682-13-git-send-email-antonio@meshcoding.com>
References: <1433340848-1682-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Markus Pargmann <mpa@pengutronix.de>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:43595 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932755AbbFCOV3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jun 2015 10:21:29 -0400
In-Reply-To: <1433340848-1682-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Pargmann <mpa@pengutronix.de>

Remove ret variable and all jumps.

Signed-off-by: Markus Pargmann <mpa@pengutronix.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/main.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 49f07e1..548e405 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -544,17 +544,14 @@ int batadv_algo_register(struct batadv_algo_ops *bat_algo_ops)
 int batadv_algo_select(struct batadv_priv *bat_priv, char *name)
 {
 	struct batadv_algo_ops *bat_algo_ops;
-	int ret = -EINVAL;
 
 	bat_algo_ops = batadv_algo_get(name);
 	if (!bat_algo_ops)
-		goto out;
+		return -EINVAL;
 
 	bat_priv->bat_algo_ops = bat_algo_ops;
-	ret = 0;
 
-out:
-	return ret;
+	return 0;
 }
 
 int batadv_algo_seq_print_text(struct seq_file *seq, void *offset)
-- 
2.4.2
