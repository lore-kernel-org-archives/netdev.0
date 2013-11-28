From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 8/8] atm: solos-pci: use DEFINE_PCI_DEVICE_TABLE macro
Date: Thu, 28 Nov 2013 12:43:39 +0900
Message-ID: <004d01ceebec$0692db60$13b89220$%han@samsung.com>
References: <004501ceebeb$27dcd970$77968c50$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'Chas Williams' <chas@cmf.nrl.navy.mil>, netdev@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net,
	'Jingoo Han' <jg1.han@samsung.com>,
	'David Woodhouse' <David.Woodhouse@intel.com>,
	'Nathan Williams' <nathan@traverse.com.au>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:42926 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754736Ab3K1Dnk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Nov 2013 22:43:40 -0500
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MWY0038DFORYK40@mailout3.samsung.com> for
 netdev@vger.kernel.org; Thu, 28 Nov 2013 12:43:39 +0900 (KST)
In-reply-to: <004501ceebeb$27dcd970$77968c50$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This macro is used to create a struct pci_device_id array.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/atm/solos-pci.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 32784d1..f718311 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -1461,7 +1461,7 @@ static void fpga_remove(struct pci_dev *dev)
 	kfree(card);
 }
 
-static struct pci_device_id fpga_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(fpga_pci_tbl) = {
 	{ 0x10ee, 0x0300, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	{ 0, }
 };
-- 
1.7.10.4
