From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next] net: bridge: fix build
Date: Sun, 18 May 2014 10:30:28 -0700
Message-ID: <1400434228-3971-1-git-send-email-ast@plumgrid.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:49132 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751570AbaERRak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 May 2014 13:30:40 -0400
Received: by mail-pb0-f42.google.com with SMTP id md12so4799528pbc.15
        for <netdev@vger.kernel.org>; Sun, 18 May 2014 10:30:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix build when BRIDGE_VLAN_FILTERING is not set

Fixes: 2796d0c648c94 ("bridge: Automatically manage port promiscuous mode")

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 net/bridge/br_private.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 2b2286d8572d..af067711574f 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -727,7 +727,7 @@ static inline u16 br_get_pvid(const struct net_port_vlans *v)
 	return VLAN_N_VID;	/* Returns invalid vid */
 }
 
-static inline int br_vlan_enabled(struct net_bridge *br);
+static inline int br_vlan_enabled(struct net_bridge *br)
 {
 	return 0;
 }
-- 
1.7.9.5
