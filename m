From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 08/17] batman-adv: Remove unused batadv_icmp_user_cmd_type
Date: Thu, 27 Oct 2016 21:01:41 +0200
Message-ID: <20161027190150.7880-9-sw@simonwunderlich.de>
References: <20161027190150.7880-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:38354 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935890AbcJ0TB5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 15:01:57 -0400
In-Reply-To: <20161027190150.7880-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/packet.h | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 6afc0b8..d2e9bbd 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -252,16 +252,6 @@ struct batadv_elp_packet {
 #define BATADV_ELP_HLEN sizeof(struct batadv_elp_packet)
 
 /**
- * enum batadv_icmp_user_cmd_type - types for batman-adv icmp cmd modes
- * @BATADV_TP_START: start a throughput meter run
- * @BATADV_TP_STOP: stop a throughput meter run
- */
-enum batadv_icmp_user_cmd_type {
-	BATADV_TP_START		= 0,
-	BATADV_TP_STOP		= 2,
-};
-
-/**
  * struct batadv_icmp_header - common members among all the ICMP packets
  * @packet_type: batman-adv packet type, part of the general header
  * @version: batman-adv protocol version, part of the genereal header
-- 
2.10.1
