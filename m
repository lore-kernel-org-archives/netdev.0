From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [net-next-2.6 PATCH 2/9] vxge: Fixed memory leak by freeing memory
 allocated for device_config
Date: Thu, 2 Jul 2009 03:13:12 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10907020312280.13763-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, support@neterion.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:37774 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752608AbZGBH0m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 03:26:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Fixed memory leak by freeing memory allocated for device_config.

Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>

---
diff -urpN patch_1/drivers/net/vxge/vxge-main.c patch_2/drivers/net/vxge/vxge-main.c
--- patch_1/drivers/net/vxge/vxge-main.c	2009-06-21 23:32:44.000000000 -0700
+++ patch_2/drivers/net/vxge/vxge-main.c	2009-06-21 23:43:43.000000000 -0700
@@ -4348,6 +4348,7 @@ vxge_probe(struct pci_dev *pdev, const s
 		vdev->vpaths[i].mac_addr_cnt = 1;
 	}
 
+	kfree(device_config);
 	vxge_debug_entryexit(VXGE_TRACE, "%s: %s:%d  Exiting...",
 		vdev->ndev->name, __func__, __LINE__);
 

