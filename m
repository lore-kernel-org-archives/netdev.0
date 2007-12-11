From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] drivers/net/ipg.c: add __devexit annotation
Date: Tue, 11 Dec 2007 23:20:30 +0100
Message-ID: <20071211222030.GD14204@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: romieu@fr.zoreil.com, sorbica@icplus.com.tw, jesse@icplus.com.tw
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:54609 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755303AbXLKWUa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 17:20:30 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipg_remove() can become __devexit.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
97ace7a0e52ceac30caae20e1a3fe72c4644bce7 
diff --git a/drivers/net/ipg.c b/drivers/net/ipg.c
index dbd23bb..285ebbc 100644
--- a/drivers/net/ipg.c
+++ b/drivers/net/ipg.c
@@ -2214,7 +2214,7 @@ static struct ethtool_ops ipg_ethtool_ops = {
 	.nway_reset   = ipg_nway_reset,
 };
 
-static void ipg_remove(struct pci_dev *pdev)
+static void __devexit ipg_remove(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct ipg_nic_private *sp = netdev_priv(dev);

