From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next 0/2] amd-xgbe: AMD XGBE driver update 2014-08-05
Date: Tue, 5 Aug 2014 11:21:13 -0500
Message-ID: <20140805162113.28088.67523.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2lp0235.outbound.protection.outlook.com ([207.46.163.235]:53295
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753581AbaHEQV3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Aug 2014 12:21:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series of patches includes fixes/updates to the driver.

- Use dma_set_mask_and_coherent to set the DMA mask
- Move the phy connect/disconnect logic to allow for module unloading

This patch series is based on net-next.

---

Tom Lendacky (2):
      amd-xgbe: Use dma_set_mask_and_coherent to set DMA mask
      amd-xgbe: Perform phy connect/disconnect at dev open/stop


 drivers/net/ethernet/amd/xgbe/xgbe-drv.c  |  122 +++++++++++++++++++++++++++++
 drivers/net/ethernet/amd/xgbe/xgbe-main.c |    3 -
 drivers/net/ethernet/amd/xgbe/xgbe-mdio.c |   98 -----------------------
 3 files changed, 122 insertions(+), 101 deletions(-)

-- 
Tom Lendacky
