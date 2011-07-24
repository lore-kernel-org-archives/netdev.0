From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH 6/6] bnx2x: use pci_pcie_cap()
Date: Sun, 24 Jul 2011 16:58:38 +0300
Message-ID: <1311515918.23243.9.camel@lb-tlvb-dmitry>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Vladislav Zolotarov" <vladz@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4917 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752834Ab1GXOLK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Jul 2011 10:11:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Zolotarov <vladz@broadcom.com>


Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 475f66f..b049fe1 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -5652,7 +5652,7 @@ static void bnx2x_init_pxp(struct bnx2x *bp)
 	int r_order, w_order;
 
 	pci_read_config_word(bp->pdev,
-			     bp->pdev->pcie_cap + PCI_EXP_DEVCTL, &devctl);
+			     pci_pcie_cap(bp->pdev) + PCI_EXP_DEVCTL, &devctl);
 	DP(NETIF_MSG_HW, "read 0x%x from devctl\n", devctl);
 	w_order = ((devctl & PCI_EXP_DEVCTL_PAYLOAD) >> 5);
 	if (bp->mrrs == -1)
-- 
1.7.2.2




