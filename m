From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH] trivial: typo hnalder -> handler
Date: Sun, 12 Feb 2012 22:29:06 +0100
Message-ID: <1329082146-644-1-git-send-email-u.kleine-koenig@pengutronix.de>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: trivial@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:50934 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754772Ab2BLV3Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2012 16:29:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 drivers/net/ethernet/micrel/ks8851.c     |    2 +-
 drivers/net/ethernet/micrel/ks8851_mll.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ks8851.c b/drivers/net/ethernet/micrel/ks8851.c
index 6b35e7d..bfebeb3 100644
--- a/drivers/net/ethernet/micrel/ks8851.c
+++ b/drivers/net/ethernet/micrel/ks8851.c
@@ -445,7 +445,7 @@ static void ks8851_init_mac(struct ks8851_net *ks)
 
 /**
  * ks8851_irq - device interrupt handler
- * @irq: Interrupt number passed from the IRQ hnalder.
+ * @irq: Interrupt number passed from the IRQ handler.
  * @pw: The private word passed to register_irq(), our struct ks8851_net.
  *
  * Disable the interrupt from happening again until we've processed the
diff --git a/drivers/net/ethernet/micrel/ks8851_mll.c b/drivers/net/ethernet/micrel/ks8851_mll.c
index e58e78e..edcc9fd 100644
--- a/drivers/net/ethernet/micrel/ks8851_mll.c
+++ b/drivers/net/ethernet/micrel/ks8851_mll.c
@@ -839,7 +839,7 @@ static void ks_update_link_status(struct net_device *netdev, struct ks_net *ks)
 
 /**
  * ks_irq - device interrupt handler
- * @irq: Interrupt number passed from the IRQ hnalder.
+ * @irq: Interrupt number passed from the IRQ handler.
  * @pw: The private word passed to register_irq(), our struct ks_net.
  *
  * This is the handler invoked to find out what happened
-- 
1.7.9
