From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v2 06/13] amd-xgbe: Add additional dynamic debug
 messages
Date: Fri, 18 Aug 2017 09:03:08 -0500
Message-ID: <20170818140308.14804.76036.stgit@tlendack-t1.amdoffice.net>
References: <20170818140209.14804.94997.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0069.outbound.protection.outlook.com ([104.47.33.69]:24848
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753608AbdHRODO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 18 Aug 2017 10:03:14 -0400
In-Reply-To: <20170818140209.14804.94997.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add some additional dynamic debug message to the driver. The new messages
will provide additional information about the PCS window calculation.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-pci.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-pci.c b/drivers/net/ethernet/amd/xgbe/xgbe-pci.c
index 1e56ad7..3e5833c 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-pci.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-pci.c
@@ -292,6 +292,10 @@ static int xgbe_pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	pdata->xpcs_window_size = 1 << (pdata->xpcs_window_size + 7);
 	pdata->xpcs_window_mask = pdata->xpcs_window_size - 1;
 	if (netif_msg_probe(pdata)) {
+		dev_dbg(dev, "xpcs window def  = %#010x\n",
+			pdata->xpcs_window_def_reg);
+		dev_dbg(dev, "xpcs window sel  = %#010x\n",
+			pdata->xpcs_window_sel_reg);
 		dev_dbg(dev, "xpcs window      = %#010x\n",
 			pdata->xpcs_window);
 		dev_dbg(dev, "xpcs window size = %#010x\n",
