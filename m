From: Stefano Brivio <stefano.brivio@polimi.it>
Subject: [patch 01/10] [RFT] bcm43xx: add core ID for PCI-E core
Date: Fri, 19 May 2006 00:00:01 +0200
Message-ID: <20060519155617.146557000@polimi.it>
References: <20060519154451.042749000@polimi.it>
Cc: Edgar Hucek <hostmaster@ed-soft.at>,
	Matthew Garrett <mjg59@srcf.ucam.org>,
	Louis E Garcia II <louisg00@bellsouth.net>,
	Stefano Brivio <stefano.brivio@polimi.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 213-156-52-114.fastres.net ([213.156.52.114]:19823 "EHLO
	213-156-52-114.fastres.net") by vger.kernel.org with ESMTP
	id S932366AbWESP4V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 May 2006 11:56:21 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=bcm43xx-pcie_core_id.diff
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add core ID for PCI-E core.

Signed-off-by: Stefano Brivio <stefano.brivio@polimi.it>

Index: wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx.h
===================================================================
--- wireless-dev.orig/drivers/net/wireless/bcm43xx/bcm43xx.h
+++ wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx.h
@@ -202,6 +202,7 @@
 #define BCM43xx_COREID_USB20_HOST       0x819
 #define BCM43xx_COREID_USB20_DEV        0x81a
 #define BCM43xx_COREID_SDIO_HOST        0x81b
+#define BCM43xx_COREID_PCIE		0x820
 
 /* Core Information Registers */
 #define BCM43xx_CIR_BASE		0xf00

--
Ciao
Stefano
