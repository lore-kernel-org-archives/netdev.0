From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 17/18] batman-adv: Prefix vis defines with BATADV_
Date: Thu, 28 Jun 2012 11:34:26 +0200
Message-ID: <1340876067-28333-18-git-send-email-ordex@autistici.org>
References: <1340876067-28333-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:30386 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932819Ab2F1Jej (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 05:34:39 -0400
In-Reply-To: <1340876067-28333-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sven Eckelmann <sven@narfation.org>

Reported-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/vis.c |    2 +-
 net/batman-adv/vis.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index 596eacc..a439ed6 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -674,7 +674,7 @@ static void batadv_purge_vis_packets(struct bat_pri=
v *bat_priv)
 				continue;
=20
 			if (batadv_has_timed_out(info->first_seen,
-						 VIS_TIMEOUT)) {
+						 BATADV_VIS_TIMEOUT)) {
 				hlist_del(node);
 				batadv_send_list_del(info);
 				kref_put(&info->refcount, batadv_free_info);
diff --git a/net/batman-adv/vis.h b/net/batman-adv/vis.h
index dad5958..16a1a6b 100644
--- a/net/batman-adv/vis.h
+++ b/net/batman-adv/vis.h
@@ -21,7 +21,7 @@
 #define _NET_BATMAN_ADV_VIS_H_
=20
 /* timeout of vis packets in miliseconds */
-#define VIS_TIMEOUT		200000
+#define BATADV_VIS_TIMEOUT		200000
=20
 int batadv_vis_seq_print_text(struct seq_file *seq, void *offset);
 void batadv_receive_server_sync_packet(struct bat_priv *bat_priv,
--=20
1.7.9.4
