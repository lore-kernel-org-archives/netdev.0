From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net-next v2] cxgb4: add new T6 pci device id's
Date: Mon, 19 Jun 2017 15:37:13 +0530
Message-ID: <1497866833-8643-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, indranil@chelsio.com, venkatesh@chelsio.com,
        sergei.shtylyov@cogentembedded.com,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:2478 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753674AbdFSKHZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 06:07:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add 0x6082, 0x6083 and 0x6084 T6 device id's

Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
V2: Correcting the commit message
---
 drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
index be7041f..99987d8 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
@@ -192,6 +192,9 @@ CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN
 	CH_PCI_ID_TABLE_FENTRY(0x6015),
 	CH_PCI_ID_TABLE_FENTRY(0x6080),
 	CH_PCI_ID_TABLE_FENTRY(0x6081),
+	CH_PCI_ID_TABLE_FENTRY(0x6082), /* Custom T6225-CR SFP28 */
+	CH_PCI_ID_TABLE_FENTRY(0x6083), /* Custom T62100-CR QSFP28 */
+	CH_PCI_ID_TABLE_FENTRY(0x6084), /* Custom T64100-CR QSFP28 */
 CH_PCI_DEVICE_ID_TABLE_DEFINE_END;
 
 #endif /* __T4_PCI_ID_TBL_H__ */
-- 
2.1.0
