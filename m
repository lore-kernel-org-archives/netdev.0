From: Olof Johansson <olof@lixom.net>
Subject: [patch 5/6] pasemi_mac: Enable GSO by default
Date: Wed, 20 Feb 2008 20:57:58 -0600
Message-ID: <20080221025930.273755000@lixom.net>
References: <20080221025753.903665000@lixom.net>
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	pasemi-linux@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:44458 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752361AbYBUDPK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Feb 2008 22:15:10 -0500
Content-Disposition: inline; filename=in-progress/pasemi_mac-enable-gso-by-default
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ethtool support will handle the runtime toggling, but we do quite a bit
better with it on by default so just leave it on for now.


Signed-off-by: Olof Johansson <olof@lixom.net>

Index: k.org/drivers/net/pasemi_mac.c
===================================================================
--- k.org.orig/drivers/net/pasemi_mac.c
+++ k.org/drivers/net/pasemi_mac.c
@@ -1750,7 +1750,7 @@ pasemi_mac_probe(struct pci_dev *pdev, c
 	netif_napi_add(dev, &mac->napi, pasemi_mac_poll, 64);
 
 	dev->features = NETIF_F_IP_CSUM | NETIF_F_LLTX | NETIF_F_SG |
-			NETIF_F_HIGHDMA;
+			NETIF_F_HIGHDMA | NETIF_F_GSO;
 
 	mac->lro_mgr.max_aggr = LRO_MAX_AGGR;
 	mac->lro_mgr.max_desc = MAX_LRO_DESCRIPTORS;

-- 

