From: David Woodhouse <dwmw2@infradead.org>
Subject: [PASEMI_MAC] Don't claim to do IPv6 checksum offload
Date: Mon, 03 Dec 2007 04:34:32 +0000
Message-ID: <1196656472.13978.130.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:34968 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752427AbXLCEeu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Dec 2007 23:34:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Woodhouse <dwmw2@infradead.org>

diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
index 09b4fde..a8db5d7 100644
--- a/drivers/net/pasemi_mac.c
+++ b/drivers/net/pasemi_mac.c
@@ -1362,7 +1362,7 @@ pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	netif_napi_add(dev, &mac->napi, pasemi_mac_poll, 64);
 
-	dev->features = NETIF_F_HW_CSUM | NETIF_F_LLTX | NETIF_F_SG;
+	dev->features = NETIF_F_IP_CSUM | NETIF_F_LLTX | NETIF_F_SG;
 
 	/* These should come out of the device tree eventually */
 	mac->dma_txch = index;

-- 
dwmw2

