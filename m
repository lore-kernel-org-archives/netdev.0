From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 v2 1/7] e1000: add support for Marvell Alaska M88E1118R PHY
Date: Fri, 28 Jan 2011 04:28:57 -0800
Message-ID: <1296217743-30093-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1296217743-30093-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Florian Fainelli <ffainelli@freebox.fr>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Dirk Brandewie <dirk.j.brandewie@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:55113 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754954Ab1A1M3I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jan 2011 07:29:08 -0500
In-Reply-To: <1296217743-30093-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <ffainelli@freebox.fr>

This patch adds support for Marvell Alask M88E188R PHY chips. Support for
other M88* PHYs is already there, so there is nothing more to add than its
PHY id.

CC: Dirk Brandewie <dirk.j.brandewie@intel.com>
Signed-off-by: Florian Fainelli <ffainelli@freebox.fr>
Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000/e1000_hw.c |    4 +++-
 drivers/net/e1000/e1000_hw.h |    1 +
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index aed223b..7501d97 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -124,6 +124,7 @@ static s32 e1000_set_phy_type(struct e1000_hw *hw)
 	case M88E1000_I_PHY_ID:
 	case M88E1011_I_PHY_ID:
 	case M88E1111_I_PHY_ID:
+	case M88E1118_E_PHY_ID:
 		hw->phy_type = e1000_phy_m88;
 		break;
 	case IGP01E1000_I_PHY_ID:
@@ -3222,7 +3223,8 @@ static s32 e1000_detect_gig_phy(struct e1000_hw *hw)
 		break;
 	case e1000_ce4100:
 		if ((hw->phy_id == RTL8211B_PHY_ID) ||
-		    (hw->phy_id == RTL8201N_PHY_ID))
+		    (hw->phy_id == RTL8201N_PHY_ID) ||
+		    (hw->phy_id == M88E1118_E_PHY_ID))
 			match = true;
 		break;
 	case e1000_82541:
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index 196eeda..c70b23d 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -2917,6 +2917,7 @@ struct e1000_host_command_info {
 #define M88E1000_14_PHY_ID M88E1000_E_PHY_ID
 #define M88E1011_I_REV_4   0x04
 #define M88E1111_I_PHY_ID  0x01410CC0
+#define M88E1118_E_PHY_ID  0x01410E40
 #define L1LXT971A_PHY_ID   0x001378E0
 
 #define RTL8211B_PHY_ID    0x001CC910
-- 
1.7.3.5

