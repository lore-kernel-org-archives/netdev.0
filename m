From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/15] i40e: add function header for i40e_get_rxfh
Date: Tue, 17 Oct 2017 11:21:07 -0700
Message-ID: <20171017182119.71989-4-jeffrey.t.kirsher@intel.com>
References: <20171017182119.71989-1-jeffrey.t.kirsher@intel.com>
Cc: Alan Brady <alan.brady@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:3560 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934569AbdJQSVm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 17 Oct 2017 14:21:42 -0400
In-Reply-To: <20171017182119.71989-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Brady <alan.brady@intel.com>

Someone left this poor little function naked with no header.  This
dresses it up in a proper function header it deserves.

Signed-off-by: Alan Brady <alan.brady@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index c250116e5e22..f4a70ef3f2e0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -3968,6 +3968,16 @@ static u32 i40e_get_rxfh_indir_size(struct net_device *netdev)
 	return I40E_HLUT_ARRAY_SIZE;
 }
 
+/**
+ * i40e_get_rxfh - get the rx flow hash indirection table
+ * @netdev: network interface device structure
+ * @indir: indirection table
+ * @key: hash key
+ * @hfunc: hash function
+ *
+ * Reads the indirection table directly from the hardware. Returns 0 on
+ * success.
+ **/
 static int i40e_get_rxfh(struct net_device *netdev, u32 *indir, u8 *key,
 			 u8 *hfunc)
 {
-- 
2.14.2
