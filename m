From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 11/18] batman-adv: Prefix bridge_loop_avoidance defines with BATADV_
Date: Thu, 28 Jun 2012 11:34:20 +0200
Message-ID: <1340876067-28333-12-git-send-email-ordex@autistici.org>
References: <1340876067-28333-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:30209 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932783Ab2F1Jee (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 05:34:34 -0400
In-Reply-To: <1340876067-28333-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sven Eckelmann <sven@narfation.org>

Reported-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bridge_loop_avoidance.c |    4 ++--
 net/batman-adv/bridge_loop_avoidance.h |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/br=
idge_loop_avoidance.c
index 0592d2b..42b8a20 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -237,7 +237,7 @@ static void batadv_bla_del_backbone_claims(struct b=
ackbone_gw *backbone_gw)
 	}
=20
 	/* all claims gone, intialize CRC */
-	backbone_gw->crc =3D BLA_CRC_INIT;
+	backbone_gw->crc =3D BATADV_BLA_CRC_INIT;
 }
=20
 /* @bat_priv: the bat priv with all the soft interface information
@@ -375,7 +375,7 @@ static struct backbone_gw *batadv_bla_get_backbone_=
gw(struct bat_priv *bat_priv,
=20
 	entry->vid =3D vid;
 	entry->lasttime =3D jiffies;
-	entry->crc =3D BLA_CRC_INIT;
+	entry->crc =3D BATADV_BLA_CRC_INIT;
 	entry->bat_priv =3D bat_priv;
 	atomic_set(&entry->request_sent, 0);
 	memcpy(entry->orig, orig, ETH_ALEN);
diff --git a/net/batman-adv/bridge_loop_avoidance.h b/net/batman-adv/br=
idge_loop_avoidance.h
index 9818b1e..58563f0 100644
--- a/net/batman-adv/bridge_loop_avoidance.h
+++ b/net/batman-adv/bridge_loop_avoidance.h
@@ -36,7 +36,7 @@ void batadv_bla_update_orig_address(struct bat_priv *=
bat_priv,
 int batadv_bla_init(struct bat_priv *bat_priv);
 void batadv_bla_free(struct bat_priv *bat_priv);
=20
-#define BLA_CRC_INIT	0
+#define BATADV_BLA_CRC_INIT	0
 #else /* ifdef CONFIG_BATMAN_ADV_BLA */
=20
 static inline int batadv_bla_rx(struct bat_priv *bat_priv, struct sk_b=
uff *skb,
--=20
1.7.9.4
