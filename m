From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next #2 37/39] ipw2200: stop using net_device.{base_addr, irq}.
Date: Fri,  6 Apr 2012 12:06:51 +0200
Message-ID: <3865105f32477233bcbaec6d335bd1ea261b6ef9.1333704409.git.romieu@fr.zoreil.com>
References: <1333704408.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>,
	Stanislav Yakovlev <stas.yakovlev@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43481 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756014Ab2DFKKk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2012 06:10:40 -0400
In-Reply-To: <1333704408.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Stanislav Yakovlev <stas.yakovlev@gmail.com>
---
 drivers/net/wireless/ipw2x00/ipw2200.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
index 2b02257..57af0fc 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -11826,10 +11826,6 @@ static int __devinit ipw_pci_probe(struct pci_dev *pdev,
 	net_dev->wireless_data = &priv->wireless_data;
 	net_dev->wireless_handlers = &ipw_wx_handler_def;
 	net_dev->ethtool_ops = &ipw_ethtool_ops;
-	net_dev->irq = pdev->irq;
-	net_dev->base_addr = (unsigned long)priv->hw_base;
-	net_dev->mem_start = pci_resource_start(pdev, 0);
-	net_dev->mem_end = net_dev->mem_start + pci_resource_len(pdev, 0) - 1;
 
 	err = sysfs_create_group(&pdev->dev.kobj, &ipw_attribute_group);
 	if (err) {
-- 
1.7.7.6
