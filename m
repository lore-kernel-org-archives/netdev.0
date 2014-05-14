From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/11] ixgbe: add space between operands to &
Date: Wed, 14 May 2014 01:54:20 -0700
Message-ID: <1400057663-4578-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1400057663-4578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:6717 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753918AbaENIyj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2014 04:54:39 -0400
In-Reply-To: <1400057663-4578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch cleans up a checkpatch.pl style warning in the ixgbe code.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 87e015d..0b9bfee 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -1579,7 +1579,7 @@ static int ixgbe_intr_test(struct ixgbe_adapter *adapter, u64 *data)
 		IXGBE_WRITE_FLUSH(&adapter->hw);
 		usleep_range(10000, 20000);
 
-		if (!(adapter->test_icr &mask)) {
+		if (!(adapter->test_icr & mask)) {
 			*data = 4;
 			break;
 		}
-- 
1.9.0
