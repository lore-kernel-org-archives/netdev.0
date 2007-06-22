From: Olof Johansson <olof@lixom.net>
Subject: [PATCH 9/9] pasemi_mac: Enable LLTX
Date: Fri, 22 Jun 2007 15:05:52 -0500
Message-ID: <20070622200552.GJ11723@lixom.net>
References: <20070622194720.614405000@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:59219 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751326AbXFVUHS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jun 2007 16:07:18 -0400
Content-Disposition: inline; filename=pasemi_mac-enable-lltx
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Enable LLTX on pasemi_mac: we're already doing sufficient locking
in the driver to enable it.


Signed-off-by: Olof Johansson <olof@lixom.net>

Index: netdev-2.6/drivers/net/pasemi_mac.c
===================================================================
--- netdev-2.6.orig/drivers/net/pasemi_mac.c
+++ netdev-2.6/drivers/net/pasemi_mac.c
@@ -1239,7 +1239,7 @@ pasemi_mac_probe(struct pci_dev *pdev, c
 	dev->set_multicast_list = pasemi_mac_set_rx_mode;
 	dev->weight = 64;
 	dev->poll = pasemi_mac_poll;
-	dev->features = NETIF_F_HW_CSUM;
+	dev->features = NETIF_F_HW_CSUM | NETIF_F_LLTX;
 
 	err = pasemi_mac_map_regs(mac);
 	if (err)

--
