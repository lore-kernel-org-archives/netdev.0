From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 6/6] ixgbe: fix PHY link setup for 82599
Date: Thu,  4 Aug 2011 05:18:18 -0700
Message-ID: <1312460298-20405-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1312460298-20405-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:1910 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753544Ab1HDMSl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Aug 2011 08:18:41 -0400
In-Reply-To: <1312460298-20405-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Fix pointer to setup_link for 82599.

This resolves some link issues when advertising modes unsupported
by the link partner.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_82599.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 3b3dd4d..34f30ec 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -213,6 +213,7 @@ static s32 ixgbe_init_phy_ops_82599(struct ixgbe_hw *hw)
 	switch (hw->phy.type) {
 	case ixgbe_phy_tn:
 		phy->ops.check_link = &ixgbe_check_phy_link_tnx;
+		phy->ops.setup_link = &ixgbe_setup_phy_link_tnx;
 		phy->ops.get_firmware_version =
 		             &ixgbe_get_phy_firmware_version_tnx;
 		break;
-- 
1.7.6

