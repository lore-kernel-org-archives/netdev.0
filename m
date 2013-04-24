From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 1/4] net/ti: add MODULE_DEVICE_TABLE + MODULE_LICENSE
Date: Wed, 24 Apr 2013 20:48:22 +0200
Message-ID: <1366829305-9752-2-git-send-email-bigeasy@linutronix.de>
References: <1366829305-9752-1-git-send-email-bigeasy@linutronix.de>
Cc: tglx@linutronix.de, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:41183 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757153Ab3DXSso (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 14:48:44 -0400
In-Reply-To: <1366829305-9752-1-git-send-email-bigeasy@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If compiled as modules each one of these modules is missing something.
With this patch the modules are loaded on demand and don't taint the
kernel due to license issues.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 drivers/net/ethernet/ti/cpsw.c          |    1 +
 drivers/net/ethernet/ti/davinci_cpdma.c |    2 ++
 drivers/net/ethernet/ti/davinci_mdio.c  |    1 +
 3 files changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 81cec00..f91c8ab 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1974,6 +1974,7 @@ static const struct of_device_id cpsw_of_mtable[] = {
 	{ .compatible = "ti,cpsw", },
 	{ /* sentinel */ },
 };
+MODULE_DEVICE_TABLE(of, cpsw_of_mtable);
 
 static struct platform_driver cpsw_driver = {
 	.driver = {
diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index 6b0a89f..49dfd59 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -1040,3 +1040,5 @@ int cpdma_control_set(struct cpdma_ctlr *ctlr, int control, int value)
 	return ret;
 }
 EXPORT_SYMBOL_GPL(cpdma_control_set);
+
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index d04a622..12aec17 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -485,6 +485,7 @@ static const struct of_device_id davinci_mdio_of_mtable[] = {
 	{ .compatible = "ti,davinci_mdio", },
 	{ /* sentinel */ },
 };
+MODULE_DEVICE_TABLE(of, davinci_mdio_of_mtable);
 
 static struct platform_driver davinci_mdio_driver = {
 	.driver = {
-- 
1.7.10.4
