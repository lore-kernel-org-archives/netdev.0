From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH 1/2] cxgb4: Add support for Chelsio's T480-CR and T440-LP-CR adapters
Date: Tue,  6 Mar 2012 14:26:36 +0530
Message-ID: <1331024197-18474-1-git-send-email-vipul@chelsio.com>
Cc: davem@davemloft.net, divy@chelsio.com, dm@chelsio.com,
	Vipul Pandya <vipul@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:15703 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758817Ab2CFI6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 03:58:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds PCI device ids for Chelsio's T480-CR and T440-LP-CR
adapters.

Signed-off-by: Vipul Pandya <vipul@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 1d88942..05ff076 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -196,6 +196,8 @@ static DEFINE_PCI_DEVICE_TABLE(cxgb4_pci_tbl) = {
 	CH_DEVICE(0x4408, 4),
 	CH_DEVICE(0x4409, 4),
 	CH_DEVICE(0x440a, 4),
+	CH_DEVICE(0x440d, 4),
+	CH_DEVICE(0x440e, 4),
 	{ 0, }
 };
 
-- 
1.7.1
