From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 5/8] atm: iphase: use DEFINE_PCI_DEVICE_TABLE macro
Date: Thu, 28 Nov 2013 12:41:07 +0900
Message-ID: <004a01ceebeb$ac185200$0448f600$%han@samsung.com>
References: <004501ceebeb$27dcd970$77968c50$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'Chas Williams' <chas@cmf.nrl.navy.mil>, netdev@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net,
	'Francois Romieu' <romieu@fr.zoreil.com>,
	'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:64370 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756119Ab3K1DlJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Nov 2013 22:41:09 -0500
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MWY00FBXFKK1J60@mailout2.samsung.com> for
 netdev@vger.kernel.org; Thu, 28 Nov 2013 12:41:08 +0900 (KST)
In-reply-to: <004501ceebeb$27dcd970$77968c50$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This macro is used to create a struct pci_device_id array.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/atm/iphase.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/iphase.c b/drivers/atm/iphase.c
index 4217f29..87b0b54 100644
--- a/drivers/atm/iphase.c
+++ b/drivers/atm/iphase.c
@@ -3258,7 +3258,7 @@ static void ia_remove_one(struct pci_dev *pdev)
       	kfree(iadev);
 }
 
-static struct pci_device_id ia_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(ia_pci_tbl) = {
 	{ PCI_VENDOR_ID_IPHASE, 0x0008, PCI_ANY_ID, PCI_ANY_ID, },
 	{ PCI_VENDOR_ID_IPHASE, 0x0009, PCI_ANY_ID, PCI_ANY_ID, },
 	{ 0,}
-- 
1.7.10.4
