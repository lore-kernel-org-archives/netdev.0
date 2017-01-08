From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 8/8] fm10k: remove FM10K_FLAG_DEBUG_STATS
Date: Sun,  8 Jan 2017 02:10:34 -0800
Message-ID: <20170108101034.119851-9-jeffrey.t.kirsher@intel.com>
References: <20170108101034.119851-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:12541 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1162284AbdAHKKw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 8 Jan 2017 05:10:52 -0500
In-Reply-To: <20170108101034.119851-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The debug statistics were removed due to complications with the ethtool
statistics API which are not possible to resolve without a new
statistics interface. The flag was left behind, but we no longer need
it.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index 75d2c80..52b9794 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -261,7 +261,6 @@ struct fm10k_intfc {
 #define FM10K_FLAG_RSS_FIELD_IPV4_UDP		(u32)(BIT(1))
 #define FM10K_FLAG_RSS_FIELD_IPV6_UDP		(u32)(BIT(2))
 #define FM10K_FLAG_SWPRI_CONFIG			(u32)(BIT(3))
-#define FM10K_FLAG_DEBUG_STATS			(u32)(BIT(4))
 	int xcast_mode;
 
 	/* Tx fast path data */
-- 
2.9.3
