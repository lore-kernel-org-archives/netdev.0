From: David Miller <davem@davemloft.net>
Subject: [PATCH net-next-2.6 2/2] tg3: Enable GRO by default.
Date: Tue, 20 Apr 2010 19:08:27 -0700 (PDT)
Message-ID: <20100420.190827.71869647.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57163
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753419Ab0DUCIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 22:08:22 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 1559224C115
	for <netdev@vger.kernel.org>; Tue, 20 Apr 2010 19:08:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This was merely an oversight when I added the *_gro_receive()
calls.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/tg3.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 0fea685..7724d7e 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -12993,6 +12993,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		tp->dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
 		if (tp->tg3_flags3 & TG3_FLG3_5755_PLUS)
 			tp->dev->features |= NETIF_F_IPV6_CSUM;
+		tp->dev->features |= NETIF_F_GRO;
 	}
 
 	/* Determine TSO capabilities */
-- 
1.7.0.4

