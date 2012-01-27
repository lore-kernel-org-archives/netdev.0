From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/11] e1000e: increase Rx PBA to prevent dropping received packets on 82566/82567
Date: Thu, 26 Jan 2012 19:08:42 -0800
Message-ID: <1327633729-14086-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1327633729-14086-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:12673 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754730Ab2A0DIz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jan 2012 22:08:55 -0500
In-Reply-To: <1327633729-14086-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

During bi-directional stress on some 82566/82567 devices, some received
packets were dropped.  Increasing the Receive Packet Buffer Allocation
resolves this.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 00b5e34..d99548c 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -4108,7 +4108,7 @@ const struct e1000_info e1000_ich9_info = {
 				  | FLAG_HAS_AMT
 				  | FLAG_HAS_FLASH
 				  | FLAG_APME_IN_WUC,
-	.pba			= 10,
+	.pba			= 18,
 	.max_hw_frame_size	= DEFAULT_JUMBO,
 	.get_variants		= e1000_get_variants_ich8lan,
 	.mac_ops		= &ich8_mac_ops,
@@ -4125,7 +4125,7 @@ const struct e1000_info e1000_ich10_info = {
 				  | FLAG_HAS_AMT
 				  | FLAG_HAS_FLASH
 				  | FLAG_APME_IN_WUC,
-	.pba			= 10,
+	.pba			= 18,
 	.max_hw_frame_size	= DEFAULT_JUMBO,
 	.get_variants		= e1000_get_variants_ich8lan,
 	.mac_ops		= &ich8_mac_ops,
-- 
1.7.7.6
