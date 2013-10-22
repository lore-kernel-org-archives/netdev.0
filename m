From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 2/3] net: tulip: use DEFINE_PCI_DEVICE_TABLE
Date: Tue, 22 Oct 2013 12:00:30 +0900
Message-ID: <000f01ceced2$dde772b0$99b65810$%han@samsung.com>
References: <000e01ceced2$a9e5d970$fdb18c50$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	'Grant Grundler' <grundler@parisc-linux.org>,
	'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:12498 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752854Ab3JVDAb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 23:00:31 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MV100B0IV0OWBH0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Tue, 22 Oct 2013 12:00:30 +0900 (KST)
In-reply-to: <000e01ceced2$a9e5d970$fdb18c50$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This macro is used to create a struct pci_device_id array.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/dec/tulip/de4x5.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/dec/tulip/de4x5.c b/drivers/net/ethernet/dec/tulip/de4x5.c
index 263b92c..c05b66d 100644
--- a/drivers/net/ethernet/dec/tulip/de4x5.c
+++ b/drivers/net/ethernet/dec/tulip/de4x5.c
@@ -2328,7 +2328,7 @@ static void de4x5_pci_remove(struct pci_dev *pdev)
 	pci_disable_device (pdev);
 }
 
-static struct pci_device_id de4x5_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(de4x5_pci_tbl) = {
         { PCI_VENDOR_ID_DEC, PCI_DEVICE_ID_DEC_TULIP,
           PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
         { PCI_VENDOR_ID_DEC, PCI_DEVICE_ID_DEC_TULIP_PLUS,
-- 
1.7.10.4
