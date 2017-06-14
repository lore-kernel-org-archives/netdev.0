From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 8/9] ixgbe: Resolve cppcheck format string warning
Date: Tue, 13 Jun 2017 17:38:09 -0700
Message-ID: <20170614003810.33189-9-jeffrey.t.kirsher@intel.com>
References: <20170614003810.33189-1-jeffrey.t.kirsher@intel.com>
Cc: Tony Nguyen <anthony.l.nguyen@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:19685 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753963AbdFNAiX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Jun 2017 20:38:23 -0400
In-Reply-To: <20170614003810.33189-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Nguyen <anthony.l.nguyen@intel.com>

cppcheck warns that the format string is incorrect in the function
ixgbe_get_strings().  Since the value cannot be negative, change the
variable to unsigned which matches the format specifier.

Signed-off-by: Tony Nguyen <anthony.l.nguyen@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 2890e926b498..72c565712a5f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -1277,7 +1277,7 @@ static void ixgbe_get_strings(struct net_device *netdev, u32 stringset,
 			      u8 *data)
 {
 	char *p = (char *)data;
-	int i;
+	unsigned int i;
 
 	switch (stringset) {
 	case ETH_SS_TEST:
-- 
2.12.2
