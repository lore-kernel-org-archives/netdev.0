From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 1/3] batman-adv: Add missing kerneldoc for extack
Date: Mon, 23 Oct 2017 17:37:02 +0200
Message-ID: <20171023153704.32120-2-sw@simonwunderlich.de>
References: <20171023153704.32120-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:54110 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751218AbdJWPhI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 11:37:08 -0400
In-Reply-To: <20171023153704.32120-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The parameter extack was added to batadv_softif_slave_add without adding
the kernel-doc for it. This caused kernel-doc warnings.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Acked-by: David Ahern <dsahern@gmail.com>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/soft-interface.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 543d2c3e0f0d..9f673cdfecf8 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -863,6 +863,7 @@ static int batadv_softif_init_late(struct net_device *dev)
  * batadv_softif_slave_add - Add a slave interface to a batadv_soft_interface
  * @dev: batadv_soft_interface used as master interface
  * @slave_dev: net_device which should become the slave interface
+ * @extack: extended ACK report struct
  *
  * Return: 0 if successful or error otherwise.
  */
-- 
2.11.0
