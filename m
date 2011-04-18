From: David Miller <davem@davemloft.net>
Subject: [PATCH 13/42] atl1c: Fix set-but-unused variable.
Date: Sun, 17 Apr 2011 17:33:11 -0700 (PDT)
Message-ID: <20110417.173311.28815537.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40560
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753845Ab1DRAdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:33:46 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 7184624C087
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 17:33:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The variable 'extra_size' is set but unused in
atl1c_configure_tx().  Just kill it off.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/atl1c/atl1c_main.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/atl1c/atl1c_main.c b/drivers/net/atl1c/atl1c_main.c
index 894d485..5c64a5d 100644
--- a/drivers/net/atl1c/atl1c_main.c
+++ b/drivers/net/atl1c/atl1c_main.c
@@ -1095,10 +1095,8 @@ static void atl1c_configure_tx(struct atl1c_adapter *adapter)
 	u32 max_pay_load;
 	u16 tx_offload_thresh;
 	u32 txq_ctrl_data;
-	u32 extra_size = 0;     /* Jumbo frame threshold in QWORD unit */
 	u32 max_pay_load_data;
 
-	extra_size = ETH_HLEN + VLAN_HLEN + ETH_FCS_LEN;
 	tx_offload_thresh = MAX_TX_OFFLOAD_THRESH;
 	AT_WRITE_REG(hw, REG_TX_TSO_OFFLOAD_THRESH,
 		(tx_offload_thresh >> 3) & TX_TSO_OFFLOAD_THRESH_MASK);
-- 
1.7.4.3

