From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 16/18] batman-adv: Prefix unicast defines with BATADV_
Date: Thu, 28 Jun 2012 11:34:25 +0200
Message-ID: <1340876067-28333-17-git-send-email-ordex@autistici.org>
References: <1340876067-28333-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:30407 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932817Ab2F1Jei (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 05:34:38 -0400
In-Reply-To: <1340876067-28333-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sven Eckelmann <sven@narfation.org>

Reported-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/originator.c |    2 +-
 net/batman-adv/unicast.c    |    2 +-
 net/batman-adv/unicast.h    |    4 ++--
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index bf9ec39a..1980696 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -370,7 +370,7 @@ static void _batadv_purge_orig(struct bat_priv *bat=
_priv)
 			}
=20
 			if (batadv_has_timed_out(orig_node->last_frag_packet,
-						 FRAG_TIMEOUT))
+						 BATADV_FRAG_TIMEOUT))
 				batadv_frag_list_free(&orig_node->frag_list);
 		}
 		spin_unlock_bh(list_lock);
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index c8da6b0..8098320 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -98,7 +98,7 @@ static int batadv_frag_create_buffer(struct list_head=
 *head)
 	int i;
 	struct frag_packet_list_entry *tfp;
=20
-	for (i =3D 0; i < FRAG_BUFFER_SIZE; i++) {
+	for (i =3D 0; i < BATADV_FRAG_BUFFER_SIZE; i++) {
 		tfp =3D kmalloc(sizeof(*tfp), GFP_ATOMIC);
 		if (!tfp) {
 			batadv_frag_list_free(head);
diff --git a/net/batman-adv/unicast.h b/net/batman-adv/unicast.h
index 9257b83..936287f 100644
--- a/net/batman-adv/unicast.h
+++ b/net/batman-adv/unicast.h
@@ -22,8 +22,8 @@
=20
 #include "packet.h"
=20
-#define FRAG_TIMEOUT 10000	/* purge frag list entries after time in ms=
 */
-#define FRAG_BUFFER_SIZE 6	/* number of list elements in buffer */
+#define BATADV_FRAG_TIMEOUT 10000 /* purge frag list entries after tim=
e in ms */
+#define BATADV_FRAG_BUFFER_SIZE 6 /* number of list elements in buffer=
 */
=20
 int batadv_frag_reassemble_skb(struct sk_buff *skb, struct bat_priv *b=
at_priv,
 			       struct sk_buff **new_skb);
--=20
1.7.9.4
