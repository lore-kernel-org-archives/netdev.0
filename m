From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 11/11] atl1c: remove MDIO_REG_ADDR_MASK in atl1c_mdio_read/write
Date: Thu, 19 Apr 2012 16:01:31 +0800
Message-ID: <1334822491-30129-12-git-send-email-xiong@qca.qualcomm.com>
References: <1334822491-30129-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <qca-linux-team@qualcomm.com>, <nic-devel@qualcomm.com>,
	xiong <xiong@qca.qualcomm.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:17048 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753946Ab2DSIDO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 04:03:14 -0400
In-Reply-To: <1334822491-30129-1-git-send-email-xiong@qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MDIO_REG_ADDR_MASK is already applied in function
atl1c_write_phy_reg and atl1c_read_phy_reg

Signed-off-by: xiong <xiong@qca.qualcomm.com>
Tested-by: Liu David <dwliu@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index e671367..df10637 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -575,7 +575,7 @@ static int atl1c_mdio_read(struct net_device *netdev, int phy_id, int reg_num)
 	struct atl1c_adapter *adapter = netdev_priv(netdev);
 	u16 result;
 
-	atl1c_read_phy_reg(&adapter->hw, reg_num & MDIO_REG_ADDR_MASK, &result);
+	atl1c_read_phy_reg(&adapter->hw, reg_num, &result);
 	return result;
 }
 
@@ -584,7 +584,7 @@ static void atl1c_mdio_write(struct net_device *netdev, int phy_id,
 {
 	struct atl1c_adapter *adapter = netdev_priv(netdev);
 
-	atl1c_write_phy_reg(&adapter->hw, reg_num & MDIO_REG_ADDR_MASK, val);
+	atl1c_write_phy_reg(&adapter->hw, reg_num, val);
 }
 
 /*
-- 
1.7.7
