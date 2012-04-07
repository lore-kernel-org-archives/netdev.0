From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 06/16] batman-adv: encourage batman to take shorter routes by changing the default hop penalty
Date: Sat,  7 Apr 2012 20:49:48 +0200
Message-ID: <1333824598-27771-7-git-send-email-ordex@autistici.org>
References: <1333824598-27771-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:60917 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754055Ab2DGStW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Apr 2012 14:49:22 -0400
In-Reply-To: <1333824598-27771-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/soft-interface.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index a5590f4..82c097d 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -834,7 +834,7 @@ struct net_device *softif_create(const char *name)
 	atomic_set(&bat_priv->gw_sel_class, 20);
 	atomic_set(&bat_priv->gw_bandwidth, 41);
 	atomic_set(&bat_priv->orig_interval, 1000);
-	atomic_set(&bat_priv->hop_penalty, 10);
+	atomic_set(&bat_priv->hop_penalty, 30);
 	atomic_set(&bat_priv->log_level, 0);
 	atomic_set(&bat_priv->fragmentation, 1);
 	atomic_set(&bat_priv->bcast_queue_left, BCAST_QUEUE_LEN);
-- 
1.7.9.4
