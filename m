From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 07/10] ixgbe: add space between operands to &
Date: Fri, 23 May 2014 05:59:13 -0700
Message-ID: <1400849956-8387-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1400849956-8387-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:36380 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751500AbaEWM7e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 May 2014 08:59:34 -0400
In-Reply-To: <1400849956-8387-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
index 24d1c93..b539e0d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -1586,7 +1586,7 @@ static int ixgbe_intr_test(struct ixgbe_adapter *adapter, u64 *data)
 		IXGBE_WRITE_FLUSH(&adapter->hw);
 		usleep_range(10000, 20000);
 
-		if (!(adapter->test_icr &mask)) {
+		if (!(adapter->test_icr & mask)) {
 			*data = 4;
 			break;
 		}
-- 
1.9.0
