From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/13] igb: Cleanups to remove return parentheses
Date: Thu, 24 Apr 2014 03:30:53 -0700
Message-ID: <1398335460-4283-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1398335460-4283-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:11394 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755211AbaDXKbH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2014 06:31:07 -0400
In-Reply-To: <1398335460-4283-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch fixes ERROR:RETURN_PARENTHESES from checkpatch file check.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 6b1b93a..a3ae9b9 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -574,7 +574,7 @@ static int igb_get_i2c_data(void *data)
 	struct e1000_hw *hw = &adapter->hw;
 	s32 i2cctl = rd32(E1000_I2CPARAMS);
 
-	return ((i2cctl & E1000_I2C_DATA_IN) != 0);
+	return !!(i2cctl & E1000_I2C_DATA_IN);
 }
 
 /**
@@ -638,7 +638,7 @@ static int igb_get_i2c_clk(void *data)
 	struct e1000_hw *hw = &adapter->hw;
 	s32 i2cctl = rd32(E1000_I2CPARAMS);
 
-	return ((i2cctl & E1000_I2C_CLK_IN) != 0);
+	return !!(i2cctl & E1000_I2C_CLK_IN);
 }
 
 static const struct i2c_algo_bit_data igb_i2c_algo = {
@@ -7054,7 +7054,7 @@ static bool igb_clean_rx_irq(struct igb_q_vector *q_vector, const int budget)
 	if (cleaned_count)
 		igb_alloc_rx_buffers(rx_ring, cleaned_count);
 
-	return (total_packets < budget);
+	return total_packets < budget;
 }
 
 static bool igb_alloc_mapped_page(struct igb_ring *rx_ring,
-- 
1.9.0
