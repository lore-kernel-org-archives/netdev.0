From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net-next] cxgb4: add new T5 pci device id's
Date: Wed, 20 Sep 2017 11:32:07 +0530
Message-ID: <1505887327-8687-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, indranil@chelsio.com, venkatesh@chelsio.com,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:58574 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751463AbdITGC3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 02:02:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add 0x50a5, 0x50a6, 0x50a7, 0x50a8 and 0x50a9 T5 device
id's.

Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
index aa28299..37d90d6 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
@@ -176,6 +176,11 @@ CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN
 	CH_PCI_ID_TABLE_FENTRY(0x50a2), /* Custom T540-KR4 */
 	CH_PCI_ID_TABLE_FENTRY(0x50a3), /* Custom T580-KR4 */
 	CH_PCI_ID_TABLE_FENTRY(0x50a4), /* Custom 2x T540-CR */
+	CH_PCI_ID_TABLE_FENTRY(0x50a5), /* Custom T522-BT */
+	CH_PCI_ID_TABLE_FENTRY(0x50a6), /* Custom T522-BT-SO */
+	CH_PCI_ID_TABLE_FENTRY(0x50a7), /* Custom T580-CR */
+	CH_PCI_ID_TABLE_FENTRY(0x50a8), /* Custom T580-KR */
+	CH_PCI_ID_TABLE_FENTRY(0x50a9), /* Custom T580-KR */
 
 	/* T6 adapters:
 	 */
-- 
2.1.0
