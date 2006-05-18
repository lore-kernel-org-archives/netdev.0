From: Stefano Brivio <stefano.brivio@polimi.it>
Subject: [patch 04/10] [RFT] bcm43xx: use PCI-E core as a PCI core, allow wireless core with rev 10
Date: Fri, 19 May 2006 00:00:04 +0200
Message-ID: <20060519155652.388397000@polimi.it>
References: <20060519154451.042749000@polimi.it>
Cc: Edgar Hucek <hostmaster@ed-soft.at>,
	Matthew Garrett <mjg59@srcf.ucam.org>,
	Louis E Garcia II <louisg00@bellsouth.net>,
	Stefano Brivio <stefano.brivio@polimi.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 213-156-52-114.fastres.net ([213.156.52.114]:14200 "EHLO
	213-156-52-114.fastres.net") by vger.kernel.org with ESMTP
	id S932372AbWESP4y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 May 2006 11:56:54 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=bcm43xx-pcie_core_probe.diff
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow for PCI-E core to be considered as PCI core. Allow revision 10 of 
wireless core.

Signed-off-by: Stefano Brivio <stefano.brivio@polimi.it>

Index: wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -2676,6 +2676,7 @@ static int bcm43xx_probe_cores(struct bc
 		core = NULL;
 		switch (core_id) {
 		case BCM43xx_COREID_PCI:
+		case BCM43xx_COREID_PCIE:
 			core = &bcm->core_pci;
 			if (core->available) {
 				printk(KERN_WARNING PFX "Multiple PCI cores found.\n");
@@ -2714,6 +2715,7 @@ static int bcm43xx_probe_cores(struct bc
 			case 6:
 			case 7:
 			case 9:
+			case 10:
 				break;
 			default:
 				printk(KERN_ERR PFX "Error: Unsupported 80211 core revision %u\n",

--
Ciao
Stefano
