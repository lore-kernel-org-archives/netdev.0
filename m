From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/2] fm10k: use generic ethtool_op_get_ts_info callback
Date: Sun,  2 Oct 2016 23:40:42 -0700
Message-ID: <1475476843-23405-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1475476843-23405-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:41818 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751830AbcJCGkq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 3 Oct 2016 02:40:46 -0400
In-Reply-To: <1475476843-23405-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This generic callback is for drivers which have software Tx timestamp
support enabled. Without this, PTP applications requesting software
timestamps may complain that the requested mode is not supported.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
index adb7cb4..5241e08 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
@@ -1182,6 +1182,7 @@ static const struct ethtool_ops fm10k_ethtool_ops = {
 	.set_rxfh		= fm10k_set_rssh,
 	.get_channels		= fm10k_get_channels,
 	.set_channels		= fm10k_set_channels,
+	.get_ts_info		= ethtool_op_get_ts_info,
 };
 
 void fm10k_set_ethtool_ops(struct net_device *dev)
-- 
2.7.4
