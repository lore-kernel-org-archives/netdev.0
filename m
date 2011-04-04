From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next-2.6 07/12] igbvf: remove bogus phys_id
Date: Mon, 04 Apr 2011 11:43:47 -0700
Message-ID: <20110404184501.915865252@linuxplumber.net>
References: <20110404184340.604594357@linuxplumber.net>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce A
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:52826 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755295Ab1DDSvP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 14:51:15 -0400
Content-Disposition: inline; filename=igvf-set-phys.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This device lies about supporting phys_id. Remove it and just
let the upper layer report not supported.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/igbvf/ethtool.c	2011-04-04 11:15:50.477019338 -0700
+++ b/drivers/net/igbvf/ethtool.c	2011-04-04 11:16:12.661202774 -0700
@@ -391,11 +391,6 @@ static int igbvf_set_wol(struct net_devi
 	return -EOPNOTSUPP;
 }
 
-static int igbvf_phys_id(struct net_device *netdev, u32 data)
-{
-	return 0;
-}
-
 static int igbvf_get_coalesce(struct net_device *netdev,
                               struct ethtool_coalesce *ec)
 {
@@ -527,7 +522,6 @@ static const struct ethtool_ops igbvf_et
 	.self_test		= igbvf_diag_test,
 	.get_sset_count		= igbvf_get_sset_count,
 	.get_strings		= igbvf_get_strings,
-	.phys_id		= igbvf_phys_id,
 	.get_ethtool_stats	= igbvf_get_ethtool_stats,
 	.get_coalesce		= igbvf_get_coalesce,
 	.set_coalesce		= igbvf_set_coalesce,


