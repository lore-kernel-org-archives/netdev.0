From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/14] fm10k: remove fm10k_get_reta_size from namespace
Date: Mon, 29 Aug 2016 02:13:36 -0700
Message-ID: <1472462026-42133-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1472462026-42133-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:61654 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756790AbcH2JNu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 29 Aug 2016 05:13:50 -0400
In-Reply-To: <1472462026-42133-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The function is only used in fm10k_ethtool.c, so make it static.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k.h         | 1 -
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c | 2 +-
 2 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index 75429f2..e985069 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -496,7 +496,6 @@ int fm10k_close(struct net_device *netdev);
 
 /* Ethtool */
 void fm10k_set_ethtool_ops(struct net_device *dev);
-u32 fm10k_get_reta_size(struct net_device *netdev);
 void fm10k_write_reta(struct fm10k_intfc *interface, const u32 *indir);
 
 /* IOV */
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
index c04cbe9..adb7cb4 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
@@ -966,7 +966,7 @@ static int fm10k_set_priv_flags(struct net_device *netdev, u32 priv_flags)
 	return 0;
 }
 
-u32 fm10k_get_reta_size(struct net_device __always_unused *netdev)
+static u32 fm10k_get_reta_size(struct net_device __always_unused *netdev)
 {
 	return FM10K_RETA_SIZE * FM10K_RETA_ENTRIES_PER_REG;
 }
-- 
2.7.4
