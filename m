From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 15/16] batman-adv: fix counter summary length
Date: Mon,  2 Jul 2012 01:43:45 +0200
Message-ID: <1341186226-10549-16-git-send-email-ordex@autistici.org>
References: <1341186226-10549-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:23565 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752103Ab2GAXno (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 19:43:44 -0400
In-Reply-To: <1341186226-10549-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Marek Lindner <lindner_marek@yahoo.de>

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Acked-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/main.h |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 8193650..b8d4ac1 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -265,9 +265,8 @@ static inline void batadv_add_counter(struct batadv=
_priv *bat_priv, size_t idx,
 static inline uint64_t batadv_sum_counter(struct batadv_priv *bat_priv=
,
 					  size_t idx)
 {
-	uint64_t *counters;
+	uint64_t *counters, sum =3D 0;
 	int cpu;
-	int sum =3D 0;
=20
 	for_each_possible_cpu(cpu) {
 		counters =3D per_cpu_ptr(bat_priv->bat_counters, cpu);
--=20
1.7.9.4
