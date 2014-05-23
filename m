From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 02/10] ixgbe: fix function-like macro, remove semicolon
Date: Fri, 23 May 2014 05:59:08 -0700
Message-ID: <1400849956-8387-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1400849956-8387-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:28124 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751386AbaEWM7a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 May 2014 08:59:30 -0400
In-Reply-To: <1400849956-8387-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch removes the semicolon from the end of the do-while(0)
construct in two function-like macros.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
index 48de859..323ecb1 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
@@ -1453,7 +1453,7 @@ do { \
 		bucket_hash ^= hi_hash_dword >> n; \
 	else if (IXGBE_ATR_SIGNATURE_HASH_KEY & (0x01 << (n + 16))) \
 		sig_hash ^= hi_hash_dword << (16 - n); \
-} while (0);
+} while (0)
 
 /**
  *  ixgbe_atr_compute_sig_hash_82599 - Compute the signature hash
@@ -1579,7 +1579,7 @@ do { \
 		bucket_hash ^= lo_hash_dword >> n; \
 	if (IXGBE_ATR_BUCKET_HASH_KEY & (0x01 << (n + 16))) \
 		bucket_hash ^= hi_hash_dword >> n; \
-} while (0);
+} while (0)
 
 /**
  *  ixgbe_atr_compute_perfect_hash_82599 - Compute the perfect filter hash
-- 
1.9.0
