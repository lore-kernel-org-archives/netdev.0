From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 4/9] igbvf: remove bogus phys_id
Date: Wed,  4 May 2011 12:30:36 -0700
Message-ID: <1304537441-2056-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1304537441-2056-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: stephen hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:65291 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755392Ab1EDTar (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2011 15:30:47 -0400
In-Reply-To: <1304537441-2056-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: stephen hemminger <shemminger@vyatta.com>

This device lies about supporting phys_id. Remove it and just
let the upper layer report not supported.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Tested-by: <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/igbvf/ethtool.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/drivers/net/igbvf/ethtool.c b/drivers/net/igbvf/ethtool.c
index 112ae15..b0b14d6 100644
--- a/drivers/net/igbvf/ethtool.c
+++ b/drivers/net/igbvf/ethtool.c
@@ -391,11 +391,6 @@ static int igbvf_set_wol(struct net_device *netdev,
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
@@ -527,7 +522,6 @@ static const struct ethtool_ops igbvf_ethtool_ops = {
 	.self_test		= igbvf_diag_test,
 	.get_sset_count		= igbvf_get_sset_count,
 	.get_strings		= igbvf_get_strings,
-	.phys_id		= igbvf_phys_id,
 	.get_ethtool_stats	= igbvf_get_ethtool_stats,
 	.get_coalesce		= igbvf_get_coalesce,
 	.set_coalesce		= igbvf_set_coalesce,
-- 
1.7.4.4

