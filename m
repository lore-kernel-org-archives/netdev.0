From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 2/8] atm: fore200e: use DEFINE_PCI_DEVICE_TABLE macro
Date: Thu, 28 Nov 2013 12:38:56 +0900
Message-ID: <004701ceebeb$5e1f3af0$1a5db0d0$%han@samsung.com>
References: <004501ceebeb$27dcd970$77968c50$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'Chas Williams' <chas@cmf.nrl.navy.mil>, netdev@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net,
	'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:24897 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756119Ab3K1Di6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Nov 2013 22:38:58 -0500
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MWY00CE6FGXGFD0@mailout1.samsung.com> for
 netdev@vger.kernel.org; Thu, 28 Nov 2013 12:38:57 +0900 (KST)
In-reply-to: <004501ceebeb$27dcd970$77968c50$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This macro is used to create a struct pci_device_id array.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/atm/fore200e.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/fore200e.c b/drivers/atm/fore200e.c
index 204814e..04fd372 100644
--- a/drivers/atm/fore200e.c
+++ b/drivers/atm/fore200e.c
@@ -2762,7 +2762,7 @@ static void fore200e_pca_remove_one(struct pci_dev *pci_dev)
 }
 
 
-static struct pci_device_id fore200e_pca_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(fore200e_pca_tbl) = {
     { PCI_VENDOR_ID_FORE, PCI_DEVICE_ID_FORE_PCA200E, PCI_ANY_ID, PCI_ANY_ID,
       0, 0, (unsigned long) &fore200e_bus[0] },
     { 0, }
-- 
1.7.10.4
