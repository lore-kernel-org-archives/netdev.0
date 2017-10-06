From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 3/4] batman-adv: Fix "line over 80 characters" checkpatch warning
Date: Fri,  6 Oct 2017 15:54:36 +0200
Message-ID: <20171006135437.26736-4-sw@simonwunderlich.de>
References: <20171006135437.26736-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:38956 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750950AbdJFOAY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 10:00:24 -0400
In-Reply-To: <20171006135437.26736-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Fixes: 242c1a28eb61 ("net: Remove useless function skb_header_release")
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/soft-interface.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 7c8288245f80..3af4b0b29b23 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -69,8 +69,8 @@ int batadv_skb_head_push(struct sk_buff *skb, unsigned int len)
 	int result;
 
 	/* TODO: We must check if we can release all references to non-payload
-	 * data using __skb_header_release in our skbs to allow skb_cow_header to
-	 * work optimally. This means that those skbs are not allowed to read
+	 * data using __skb_header_release in our skbs to allow skb_cow_header
+	 * to work optimally. This means that those skbs are not allowed to read
 	 * or write any data which is before the current position of skb->data
 	 * after that call and thus allow other skbs with the same data buffer
 	 * to write freely in that area.
-- 
2.11.0
