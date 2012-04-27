From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/6] e1000e: Enable DMA Burst Mode on 82574 by default.
Date: Fri, 27 Apr 2012 02:36:49 -0700
Message-ID: <1335519413-1892-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1335519413-1892-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Matthew Vick <matthew.vick@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:58719 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759925Ab2D0Jg4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2012 05:36:56 -0400
In-Reply-To: <1335519413-1892-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Vick <matthew.vick@intel.com>

Performance testing has shown that enabling DMA burst on 82574
improves performance on small packets, so enable it by default.

Signed-off-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/82571.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/82571.c b/drivers/net/ethernet/intel/e1000e/82571.c
index 609c18c..d0ea316 100644
--- a/drivers/net/ethernet/intel/e1000e/82571.c
+++ b/drivers/net/ethernet/intel/e1000e/82571.c
@@ -2062,7 +2062,8 @@ const struct e1000_info e1000_82574_info = {
 				  | FLAG_HAS_CTRLEXT_ON_LOAD,
 	.flags2			  = FLAG2_CHECK_PHY_HANG
 				  | FLAG2_DISABLE_ASPM_L0S
-				  | FLAG2_NO_DISABLE_RX,
+				  | FLAG2_NO_DISABLE_RX
+				  | FLAG2_DMA_BURST,
 	.pba			= 32,
 	.max_hw_frame_size	= DEFAULT_JUMBO,
 	.get_variants		= e1000_get_variants_82571,
-- 
1.7.7.6
