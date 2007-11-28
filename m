From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 3/4] r6040: erroneous dev->priv
Date: Wed, 28 Nov 2007 23:10:39 +0100
Message-ID: <20071128221039.GC19096@electric-eye.fr.zoreil.com>
References: <20071127204536.61bf7921.akpm@google.com> <20071127230601.fbb60024.akpm@linux-foundation.org> <20071128220812.GA12598@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Sten Wang <sten.wang@rdc.com.tw>, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:37376 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759243AbXK1WPV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2007 17:15:21 -0500
Content-Disposition: inline
In-Reply-To: <20071128220812.GA12598@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/r6040.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index a106add..71aa478 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -674,7 +674,7 @@ static void r6040_up(struct net_device *dev)
 static void r6040_timer(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *)data;
-	struct r6040_private *lp = netdev_priv(dev->priv);
+	struct r6040_private *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->base;
 	u16 phy_mode;
 
-- 
1.5.3.3

