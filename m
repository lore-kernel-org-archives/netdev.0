From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 06/19] batman-adv: avoid characters requiring shell escapes in protocol names
Date: Mon, 18 Jun 2012 22:39:10 +0200
Message-ID: <1340051963-14836-7-git-send-email-ordex@autistici.org>
References: <1340051963-14836-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:41448 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753078Ab2FRUjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2012 16:39:09 -0400
In-Reply-To: <1340051963-14836-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Reported-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_iv_ogm.c |    2 +-
 net/batman-adv/main.c       |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 99ec218..e94ac0b 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -1241,7 +1241,7 @@ static int bat_iv_ogm_receive(struct sk_buff *skb,
 }
 
 static struct bat_algo_ops batman_iv __read_mostly = {
-	.name = "BATMAN IV",
+	.name = "BATMAN_IV",
 	.bat_iface_enable = bat_iv_ogm_iface_enable,
 	.bat_iface_disable = bat_iv_ogm_iface_disable,
 	.bat_iface_update_mac = bat_iv_ogm_iface_update_mac,
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index bd83aa4..65b4f08 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -40,7 +40,7 @@
  * list traversals just rcu-locked */
 struct list_head hardif_list;
 static int (*recv_packet_handler[256])(struct sk_buff *, struct hard_iface *);
-char bat_routing_algo[20] = "BATMAN IV";
+char bat_routing_algo[20] = "BATMAN_IV";
 static struct hlist_head bat_algo_list;
 
 unsigned char broadcast_addr[] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
-- 
1.7.9.4
