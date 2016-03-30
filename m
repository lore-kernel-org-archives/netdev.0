From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 08/11] ixgbe: make __ixgbe_setup_tc static
Date: Wed, 30 Mar 2016 16:00:52 -0700
Message-ID: <1459378855-139837-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459378855-139837-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:65047 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753508AbcC3XBD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Mar 2016 19:01:03 -0400
In-Reply-To: <1459378855-139837-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This function is only used in ixgbe_main.c
Resolves a "missing prototype" warning when building the driver with W=1

Reported-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Acked-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 267a507..f5736a3 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -8376,8 +8376,8 @@ err_out:
 	return -EINVAL;
 }
 
-int __ixgbe_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
-		     struct tc_to_netdev *tc)
+static int __ixgbe_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
+			    struct tc_to_netdev *tc)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
 
-- 
2.5.5
