From: brice@myri.com
Subject: [patch 2/4] myri10ge - Drop ununsed nvidia chipset id
Date: Mon, 03 Jul 2006 18:02:32 -0400
Message-ID: <20060703220517.025650000@loulous.org>
References: <20060703220230.606593000@myri.com>
Cc: Brice Goglin <brice@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:43703 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S932145AbWGCWII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2006 18:08:08 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=myri10ge2-drop_ck804_pci_id.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The workaround for the AER capability of the nVidia chipset has been
removed, we don't need this PCI id anymore. Drop it.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    2 --
 1 file changed, 2 deletions(-)

Index: linux-mm/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-mm.orig/drivers/net/myri10ge/myri10ge.c	2006-07-03 16:01:33.000000000 -0400
+++ linux-mm/drivers/net/myri10ge/myri10ge.c	2006-07-03 16:01:39.000000000 -0400
@@ -2196,8 +2196,6 @@
  * any other device, except if forced with myri10ge_ecrc_enable > 1.
  */
 
-#define PCI_DEVICE_ID_NVIDIA_NFORCE_CK804_PCIE	0x005d
-
 static void myri10ge_enable_ecrc(struct myri10ge_priv *mgp)
 {
 	struct pci_dev *bridge = mgp->pdev->bus->self;

