From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next] cxgb4: Add PCI device ids for few more T5 and T6 adapters
Date: Mon,  6 Jul 2015 22:38:34 +0530
Message-ID: <1436202514-29808-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:32982 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753554AbbGFLyq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 07:54:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
index d7ca106..8353a6c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
@@ -142,6 +142,8 @@ CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN
 	CH_PCI_ID_TABLE_FENTRY(0x5013),	/* T580-chr */
 	CH_PCI_ID_TABLE_FENTRY(0x5014),	/* T580-so */
 	CH_PCI_ID_TABLE_FENTRY(0x5015),	/* T502-bt */
+	CH_PCI_ID_TABLE_FENTRY(0x5016),	/* T580-OCP-SO */
+	CH_PCI_ID_TABLE_FENTRY(0x5017),	/* T520-OCP-SO */
 	CH_PCI_ID_TABLE_FENTRY(0x5080),	/* Custom T540-cr */
 	CH_PCI_ID_TABLE_FENTRY(0x5081),	/* Custom T540-LL-cr */
 	CH_PCI_ID_TABLE_FENTRY(0x5082),	/* Custom T504-cr */
@@ -155,6 +157,22 @@ CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN
 	CH_PCI_ID_TABLE_FENTRY(0x5090),	/* Custom T540-CR */
 	CH_PCI_ID_TABLE_FENTRY(0x5091),	/* Custom T522-CR */
 	CH_PCI_ID_TABLE_FENTRY(0x5092),	/* Custom T520-CR */
+
+	/* T6 adapters:
+	 */
+	CH_PCI_ID_TABLE_FENTRY(0x6001),
+	CH_PCI_ID_TABLE_FENTRY(0x6002),
+	CH_PCI_ID_TABLE_FENTRY(0x6003),
+	CH_PCI_ID_TABLE_FENTRY(0x6004),
+	CH_PCI_ID_TABLE_FENTRY(0x6005),
+	CH_PCI_ID_TABLE_FENTRY(0x6006),
+	CH_PCI_ID_TABLE_FENTRY(0x6007),
+	CH_PCI_ID_TABLE_FENTRY(0x6009),
+	CH_PCI_ID_TABLE_FENTRY(0x600d),
+	CH_PCI_ID_TABLE_FENTRY(0x6010),
+	CH_PCI_ID_TABLE_FENTRY(0x6011),
+	CH_PCI_ID_TABLE_FENTRY(0x6014),
+	CH_PCI_ID_TABLE_FENTRY(0x6015),
 CH_PCI_DEVICE_ID_TABLE_DEFINE_END;
 
 #endif /* __T4_PCI_ID_TBL_H__ */
-- 
2.3.4
