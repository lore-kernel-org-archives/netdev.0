From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net] cxgb4: add new T5 pci device id's
Date: Thu, 13 Jul 2017 18:45:07 +0530
Message-ID: <1499951707-6397-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, indranil@chelsio.com, venkatesh@chelsio.com,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:6389 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751176AbdGMNPv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2017 09:15:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add 0x50a3 and 0x50a4 T5 device id's

Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
index 99987d8..aa28299 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
@@ -174,6 +174,8 @@ CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN
 	CH_PCI_ID_TABLE_FENTRY(0x50a0), /* Custom T540-CR */
 	CH_PCI_ID_TABLE_FENTRY(0x50a1), /* Custom T540-CR */
 	CH_PCI_ID_TABLE_FENTRY(0x50a2), /* Custom T540-KR4 */
+	CH_PCI_ID_TABLE_FENTRY(0x50a3), /* Custom T580-KR4 */
+	CH_PCI_ID_TABLE_FENTRY(0x50a4), /* Custom 2x T540-CR */
 
 	/* T6 adapters:
 	 */
-- 
2.1.0
