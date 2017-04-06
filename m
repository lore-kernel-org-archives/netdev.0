From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/7] fm10k: update function header comment for fm10k_get_stats64
Date: Thu,  6 Apr 2017 00:54:54 -0700
Message-ID: <20170406075456.27757-6-jeffrey.t.kirsher@intel.com>
References: <20170406075456.27757-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:39569 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756633AbdDFHz7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 03:55:59 -0400
In-Reply-To: <20170406075456.27757-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Re-word the comment to avoid stating that we return a value for this
void function. Additionally, there is no need to mention older kernels,
since this is the upstream kernel.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 344a392f7a76..70cd121d465f 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -1115,8 +1115,8 @@ void fm10k_reset_rx_state(struct fm10k_intfc *interface)
  * @netdev: network interface device structure
  * @stats: storage space for 64bit statistics
  *
- * Returns 64bit statistics, for use in the ndo_get_stats64 callback. This
- * function replaces fm10k_get_stats for kernels which support it.
+ * Obtain 64bit statistics in a way that is safe for both 32bit and 64bit
+ * architectures.
  */
 static void fm10k_get_stats64(struct net_device *netdev,
 			      struct rtnl_link_stats64 *stats)
-- 
2.12.2
