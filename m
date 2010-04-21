From: David Miller <davem@davemloft.net>
Subject: [PATCH net-next-2.6 1/2] niu: Enable GRO by default.
Date: Tue, 20 Apr 2010 19:08:25 -0700 (PDT)
Message-ID: <20100420.190825.14335753.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57160
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753419Ab0DUCIU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 22:08:20 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id DE6B724C112
	for <netdev@vger.kernel.org>; Tue, 20 Apr 2010 19:08:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This was merely an oversight when I added the napi_gro_receive()
calls.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/niu.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index ef94022..493e25c 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -9838,7 +9838,7 @@ static int __devinit niu_pci_init_one(struct pci_dev *pdev,
 		}
 	}
 
-	dev->features |= (NETIF_F_SG | NETIF_F_HW_CSUM);
+	dev->features |= (NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_GRO);
 
 	np->regs = pci_ioremap_bar(pdev, 0);
 	if (!np->regs) {
-- 
1.7.0.4

