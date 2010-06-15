From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] ixgbe: add comment on SFP+ ID for Active DA
Date: Tue, 15 Jun 2010 12:23:17 -0700
Message-ID: <20100615192316.2973.29967.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.westchester.pa.mail.comcast.net ([76.96.62.16]:34812
	"EHLO qmta01.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754138Ab0FOTXi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 15:23:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

These comments were forgotten in the initial patch to add this
functionality.  This patch corrects that.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_phy.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_phy.c b/drivers/net/ixgbe/ixgbe_phy.c
index 09e1911..48325a5 100644
--- a/drivers/net/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ixgbe/ixgbe_phy.c
@@ -575,6 +575,8 @@ s32 ixgbe_identify_sfp_module_generic(struct ixgbe_hw *hw)
 		 * 4    SFP_DA_CORE1 - 82599-specific
 		 * 5    SFP_SR/LR_CORE0 - 82599-specific
 		 * 6    SFP_SR/LR_CORE1 - 82599-specific
+		 * 7    SFP_act_lmt_DA_CORE0 - 82599-specific
+		 * 8    SFP_act_lmt_DA_CORE1 - 82599-specific
 		 */
 		if (hw->mac.type == ixgbe_mac_82598EB) {
 			if (cable_tech & IXGBE_SFF_DA_PASSIVE_CABLE)

