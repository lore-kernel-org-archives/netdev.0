From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 02/16] i40e: Make it clear a parameter is never used
Date: Tue, 13 Oct 2015 23:59:42 -0700
Message-ID: <1444805996-3877-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444805996-3877-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:47517 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752468AbbJNG77 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2015 02:59:59 -0400
In-Reply-To: <1444805996-3877-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

Flag the filter_mask parameter as __always_unused in the
ndo_bridge_getlink function.

Change-ID: Ifc1e99c7fb84bcbf81cf7b0ac891ad8ca956ffb2
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index a484f22..d5d8b66 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8336,7 +8336,8 @@ static int i40e_ndo_bridge_setlink(struct net_device *dev,
  **/
 static int i40e_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 				   struct net_device *dev,
-				   u32 filter_mask, int nlflags)
+				   u32 __always_unused filter_mask,
+				   int nlflags)
 {
 	struct i40e_netdev_priv *np = netdev_priv(dev);
 	struct i40e_vsi *vsi = np->vsi;
-- 
2.4.3
