From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net-next] cxgb4: Add new T5 and T6 pci device id's
Date: Thu, 16 Feb 2017 12:25:52 +0530
Message-ID: <1487228152-29428-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, Ganesh Goudar <ganeshgr@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:50061 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753666AbdBPG4D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 01:56:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
index ecf3ccc..a323185 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
@@ -169,6 +169,9 @@ CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN
 	CH_PCI_ID_TABLE_FENTRY(0x509b),	/* Custom T540-CR LOM */
 	CH_PCI_ID_TABLE_FENTRY(0x509c),	/* Custom T520-CR*/
 	CH_PCI_ID_TABLE_FENTRY(0x509d),	/* Custom T540-CR*/
+	CH_PCI_ID_TABLE_FENTRY(0x509e), /* Custom T520-CR */
+	CH_PCI_ID_TABLE_FENTRY(0x509f), /* Custom T540-CR */
+	CH_PCI_ID_TABLE_FENTRY(0x50a0), /* Custom T540-CR */
 
 	/* T6 adapters:
 	 */
@@ -185,6 +188,8 @@ CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN
 	CH_PCI_ID_TABLE_FENTRY(0x6011),
 	CH_PCI_ID_TABLE_FENTRY(0x6014),
 	CH_PCI_ID_TABLE_FENTRY(0x6015),
+	CH_PCI_ID_TABLE_FENTRY(0x6080),
+	CH_PCI_ID_TABLE_FENTRY(0x6081),
 CH_PCI_DEVICE_ID_TABLE_DEFINE_END;
 
 #endif /* __T4_PCI_ID_TBL_H__ */
-- 
2.1.0
