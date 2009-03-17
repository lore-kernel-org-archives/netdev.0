From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 30/30] solos: Disable DMA until we have an FPGA update with
 it actually implemented.
Date: Tue, 17 Mar 2009 21:29:37 +0000
Message-ID: <1237325377.27681.360.camel@macbook.infradead.org>
References: <1237310370.27681.314.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37678 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758030AbZCQV3x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 17:29:53 -0400
Received: from macbook.infradead.org ([2001:8b0:10b:1:216:eaff:fe05:bbb8])
	by casper.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1Ljgr9-0001wd-JU
	for netdev@vger.kernel.org; Tue, 17 Mar 2009 21:29:51 +0000
In-Reply-To: <1237310370.27681.314.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/atm/solos-pci.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 6fe8f8f..bc3079d 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -1097,7 +1097,7 @@ static int fpga_probe(struct pci_dev *dev, const struct pci_device_id *id)
 	dev_info(&dev->dev, "Solos FPGA Version %d.%02d svn-%d\n",
 		 major_ver, minor_ver, fpga_ver);
 
-	if (fpga_ver > 27)
+	if (0 && fpga_ver > 27)
 		card->using_dma = 1;
 	else {
 		/* Set RX empty flag for all ports */
-- 
1.6.0.6

