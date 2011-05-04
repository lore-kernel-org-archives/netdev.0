From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 6/9] ixgbe: fix typo error with software defined pins on 82599
Date: Wed,  4 May 2011 12:30:38 -0700
Message-ID: <1304537441-2056-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1304537441-2056-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:65291 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754312Ab1EDTas (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2011 15:30:48 -0400
In-Reply-To: <1304537441-2056-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Correcting a simple typo with enabling software defined pins.  I don't
believe this was causing any issues but this is how it was meant to be
implemented.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Evan Swanson <evan.swanson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 9160811..bd3d21d 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3862,9 +3862,10 @@ static void ixgbe_setup_gpie(struct ixgbe_adapter *adapter)
 	if (adapter->flags & IXGBE_FLAG_FAN_FAIL_CAPABLE)
 		gpie |= IXGBE_SDP1_GPIEN;
 
-	if (hw->mac.type == ixgbe_mac_82599EB)
+	if (hw->mac.type == ixgbe_mac_82599EB) {
 		gpie |= IXGBE_SDP1_GPIEN;
 		gpie |= IXGBE_SDP2_GPIEN;
+	}
 
 	IXGBE_WRITE_REG(hw, IXGBE_GPIE, gpie);
 }
-- 
1.7.4.4

