From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 5/7] 8139cp: removal of useless BUG_ON() check
Date: Thu, 31 Aug 2006 22:51:52 +0200
Message-ID: <20060831205152.GE14181@electric-eye.fr.zoreil.com>
References: <20060831204717.GA13650@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, Pierre Ossman <drzeus-list@drzeus.cx>,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:60075 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S932446AbWHaUwD
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 16:52:03 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060831204717.GA13650@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

netdev_priv() will provide a nice oops a few lines before
the BUG_ON() check.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

---

 drivers/net/8139cp.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

e68970e7543815133224f79a858e7c9e0c42f4de
diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index 9aef517..94ab3c3 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -2009,7 +2009,6 @@ static void cp_remove_one (struct pci_de
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct cp_private *cp = netdev_priv(dev);
 
-	BUG_ON(!dev);
 	unregister_netdev(dev);
 	iounmap(cp->regs);
 	if (cp->wol_enabled)
-- 
1.3.1

