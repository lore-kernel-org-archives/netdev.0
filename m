From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 09/17] batman-adv: fix batadv_forw_packet kerneldoc for list attribute
Date: Thu, 27 Oct 2016 21:01:42 +0200
Message-ID: <20161027190150.7880-10-sw@simonwunderlich.de>
References: <20161027190150.7880-1-sw@simonwunderlich.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:38358 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S942259AbcJ0TB6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 15:01:58 -0400
In-Reply-To: <20161027190150.7880-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Lüssing <linus.luessing@c0d3.blue>

The forw_packet list node is wrongly attributed to the icmp socket code.

Signed-off-by: Linus Lüssing <linus.luessing@c0d3.blue>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/types.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index b3dd1a3..97336ec 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -1363,7 +1363,7 @@ struct batadv_skb_cb {
 
 /**
  * struct batadv_forw_packet - structure for bcast packets to be sent/forwarded
- * @list: list node for batadv_socket_client::queue_list
+ * @list: list node for batadv_priv::forw_{bat,bcast}_list
  * @send_time: execution time for delayed_work (packet sending)
  * @own: bool for locally generated packets (local OGMs are re-scheduled after
  *  sending)
-- 
2.10.1
