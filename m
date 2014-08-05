From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v2 0/2] amd-xgbe: AMD XGBE driver update 2014-08-05
Date: Tue, 5 Aug 2014 13:30:32 -0500
Message-ID: <20140805183032.32561.85828.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2lp0203.outbound.protection.outlook.com ([207.46.163.203]:5143
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756031AbaHESas (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Aug 2014 14:30:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series of patches includes fixes/updates to the driver.

- Use dma_set_mask_and_coherent to set the DMA mask
- Move the phy connect/disconnect logic to allow for module unloading

This patch series is based on net-next.

Changes in V2:
- Check the return value of the dma_set_mask_and_coherent call

---

Tom Lendacky (2):
      amd-xgbe: Use dma_set_mask_and_coherent to set DMA mask
      amd-xgbe: Perform phy connect/disconnect at dev open/stop


 drivers/net/ethernet/amd/xgbe/xgbe-drv.c  |  122 +++++++++++++++++++++++++++++
 drivers/net/ethernet/amd/xgbe/xgbe-main.c |    7 +-
 drivers/net/ethernet/amd/xgbe/xgbe-mdio.c |   98 -----------------------
 3 files changed, 126 insertions(+), 101 deletions(-)

-- 
Tom Lendacky
