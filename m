From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 1/3] net: cxgb4vf: use DEFINE_PCI_DEVICE_TABLE
Date: Tue, 22 Oct 2013 11:59:02 +0900
Message-ID: <000e01ceced2$a9e5d970$fdb18c50$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Casey Leedom' <leedom@chelsio.com>,
	'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:43500 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752961Ab3JVC7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 22:59:05 -0400
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MV100ADNUYCNTI0@mailout2.samsung.com> for
 netdev@vger.kernel.org; Tue, 22 Oct 2013 11:59:03 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This macro is used to create a struct pci_device_id array.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 43bb012..5f90ec5 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -2905,7 +2905,7 @@ static void cxgb4vf_pci_shutdown(struct pci_dev *pdev)
 #define CH_DEVICE(devid, idx) \
 	{ PCI_VENDOR_ID_CHELSIO, devid, PCI_ANY_ID, PCI_ANY_ID, 0, 0, idx }
 
-static struct pci_device_id cxgb4vf_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(cxgb4vf_pci_tbl) = {
 	CH_DEVICE(0xb000, 0),	/* PE10K FPGA */
 	CH_DEVICE(0x4800, 0),	/* T440-dbg */
 	CH_DEVICE(0x4801, 0),	/* T420-cr */
-- 
1.7.10.4
