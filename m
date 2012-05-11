From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 13/15] batman-adv: fix checkpatch string complaint
Date: Fri, 11 May 2012 14:21:30 +0200
Message-ID: <1336738892-7401-14-git-send-email-ordex@autistici.org>
References: <1336738892-7401-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:58889 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758383Ab2EKMZg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 08:25:36 -0400
In-Reply-To: <1336738892-7401-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Regression introduced by: f76d019194e0a88c57371df169ecc979690a04c2

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_iv_ogm.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index bafb473..abd10c4 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -1061,8 +1061,8 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 
 	if (batman_ogm_packet->flags & NOT_BEST_NEXT_HOP) {
 		bat_dbg(DBG_BATMAN, bat_priv,
-			"Drop packet: ignoring all packets not forwarded from "
-			"the best next hop (sender: %pM)\n", ethhdr->h_source);
+			"Drop packet: ignoring all packets not forwarded from the best next hop (sender: %pM)\n",
+			ethhdr->h_source);
 		return;
 	}
 
-- 
1.7.9.4
