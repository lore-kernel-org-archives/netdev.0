From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH 16/20] sunhme: extending (hw_/wanted_/vlan_)features fields to a bitmap.
Date: Tue,  5 Apr 2011 17:44:21 -0700
Message-ID: <1302050665-10460-17-git-send-email-maheshb@google.com>
References: <1302050665-10460-1-git-send-email-maheshb@google.com>
 <1302050665-10460-2-git-send-email-maheshb@google.com>
 <1302050665-10460-3-git-send-email-maheshb@google.com>
 <1302050665-10460-4-git-send-email-maheshb@google.com>
 <1302050665-10460-5-git-send-email-maheshb@google.com>
 <1302050665-10460-6-git-send-email-maheshb@google.com>
 <1302050665-10460-7-git-send-email-maheshb@google.com>
 <1302050665-10460-8-git-send-email-maheshb@google.com>
 <1302050665-10460-9-git-send-email-maheshb@google.com>
 <1302050665-10460-10-git-send-email-maheshb@google.com>
 <1302050665-10460-11-git-send-email-maheshb@google.com>
 <1302050665-10460-12-git-send-email-maheshb@google.com>
 <1302050665-10460-13-git-send-email-maheshb@google.com>
 <1302050665-10460-14-git-send-email-maheshb@google.com>
 <1302050665-10460-15-git-send-email-maheshb@google.com>
 <1302050665-10460-16-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:28070 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754245Ab1DFAo4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 20:44:56 -0400
In-Reply-To: <1302050665-10460-16-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Converting current use of (hw_/wanted_/vlan_)features to
legacy_(hw_/wanted_/vlan_)features to differntiate from the proposed usage.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/sunhme.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/sunhme.c b/drivers/net/sunhme.c
index 80e907d..9d05f86 100644
--- a/drivers/net/sunhme.c
+++ b/drivers/net/sunhme.c
@@ -2788,8 +2788,8 @@ static int __devinit happy_meal_sbus_probe_one(struct platform_device *op, int i
 	dev->ethtool_ops = &hme_ethtool_ops;
 
 	/* Happy Meal can do it all... */
-	dev->hw_features = NETIF_F_SG | NETIF_F_HW_CSUM;
-	dev->features |= dev->hw_features | NETIF_F_RXCSUM;
+	dev->legacy_hw_features = NETIF_F_SG | NETIF_F_HW_CSUM;
+	dev->legacy_features |= dev->legacy_hw_features | NETIF_F_RXCSUM;
 
 	dev->irq = op->archdata.irqs[0];
 
@@ -3114,8 +3114,8 @@ static int __devinit happy_meal_pci_probe(struct pci_dev *pdev,
 	dev->dma = 0;
 
 	/* Happy Meal can do it all... */
-	dev->hw_features = NETIF_F_SG | NETIF_F_HW_CSUM;
-	dev->features |= dev->hw_features | NETIF_F_RXCSUM;
+	dev->legacy_hw_features = NETIF_F_SG | NETIF_F_HW_CSUM;
+	dev->legacy_features |= dev->legacy_hw_features | NETIF_F_RXCSUM;
 
 #if defined(CONFIG_SBUS) && defined(CONFIG_PCI)
 	/* Hook up PCI register/descriptor accessors. */
-- 
1.7.3.1

