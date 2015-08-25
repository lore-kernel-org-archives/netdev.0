From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 14/15] batman-adv: Fix conditional statements indentation
Date: Tue, 25 Aug 2015 13:02:38 +0200
Message-ID: <1440500559-28368-15-git-send-email-antonio__3235.17267029292$1440502258$gmane$org@meshcoding.com>
References: <1440500559-28368-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:44646 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755393AbbHYLas (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2015 07:30:48 -0400
In-Reply-To: <1440500559-28368-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

commit 29b9256e6631 ("batman-adv: consider outgoing interface in OGM
sending") incorrectly indented the interface check code.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/bat_iv_ogm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index df54118..5c12200 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -968,7 +968,7 @@ static void batadv_iv_ogm_schedule(struct batadv_hard_iface *hard_iface)
 	rcu_read_lock();
 	list_for_each_entry_rcu(tmp_hard_iface, &batadv_hardif_list, list) {
 		if (tmp_hard_iface->soft_iface != hard_iface->soft_iface)
-				continue;
+			continue;
 		batadv_iv_ogm_queue_add(bat_priv, *ogm_buff,
 					*ogm_buff_len, hard_iface,
 					tmp_hard_iface, 1, send_time);
-- 
2.5.0
