From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 11/27] ixgbe: fix X540 phy id to correct value
Date: Fri, 10 Dec 2010 02:01:43 -0800
Message-ID: <1291975303-30437-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.emeryville.ca.mail.comcast.net ([76.96.30.24]:36003 "EHLO
	qmta02.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751198Ab0LJKB5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 05:01:57 -0500
To: davem@davemloft.net
To: davem@davemleft.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

The existing PHY ID for X540 was from early production hardware and
is no longer correct.  This patch corrects that.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_phy.c  |    2 +-
 drivers/net/ixgbe/ixgbe_type.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_phy.c b/drivers/net/ixgbe/ixgbe_phy.c
index c445fbc..8f7123e 100644
--- a/drivers/net/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ixgbe/ixgbe_phy.c
@@ -115,7 +115,7 @@ static enum ixgbe_phy_type ixgbe_get_phy_type_from_id(u32 phy_id)
 	case TN1010_PHY_ID:
 		phy_type = ixgbe_phy_tn;
 		break;
-	case AQ1202_PHY_ID:
+	case X540_PHY_ID:
 		phy_type = ixgbe_phy_aq;
 		break;
 	case QT2022_PHY_ID:
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 0f80893..59f6d0a 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -999,7 +999,7 @@
 /* PHY IDs*/
 #define TN1010_PHY_ID    0x00A19410
 #define TNX_FW_REV       0xB
-#define AQ1202_PHY_ID    0x03A1B440
+#define X540_PHY_ID      0x01540200
 #define QT2022_PHY_ID    0x0043A400
 #define ATH_PHY_ID       0x03429050
 #define AQ_FW_REV        0x20
-- 
1.7.3.2

