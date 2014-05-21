From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/15] i40evf: make ethtool_ops const
Date: Wed, 21 May 2014 05:01:05 -0700
Message-ID: <1400673673-31626-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1400673673-31626-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Ben Hutchings <ben@decadent.org.uk>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:21038 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752342AbaEUMB2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 May 2014 08:01:28 -0400
In-Reply-To: <1400673673-31626-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Const-ify the ethtool_ops structure, as it is extremely unlikely to
change at runtime. Suggested by Ben Hutchings.

CC: Ben Hutchings <ben@decadent.org.uk>
Change-ID: I1ccb1b7c3ea801cc934447599a35910e7c93d321
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
index b0f6270..c079166f 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
@@ -680,7 +680,7 @@ static int i40evf_set_rxfh_indir(struct net_device *netdev, const u32 *indir)
 	return 0;
 }
 
-static struct ethtool_ops i40evf_ethtool_ops = {
+static const struct ethtool_ops i40evf_ethtool_ops = {
 	.get_settings		= i40evf_get_settings,
 	.get_drvinfo		= i40evf_get_drvinfo,
 	.get_link		= ethtool_op_get_link,
-- 
1.9.0
