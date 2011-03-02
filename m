From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 2/3] igb: fix sparse warning
Date: Wed,  2 Mar 2011 03:45:40 -0800
Message-ID: <1299066341-13820-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299066341-13820-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:23803 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756953Ab1CBLqp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2011 06:46:45 -0500
In-Reply-To: <1299066341-13820-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported-by: Stephen Hemminger <shemminger@vyatta.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/igbvf/vf.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/igbvf/vf.c b/drivers/net/igbvf/vf.c
index 74486a8..af3822f 100644
--- a/drivers/net/igbvf/vf.c
+++ b/drivers/net/igbvf/vf.c
@@ -220,7 +220,7 @@ static u32 e1000_hash_mc_addr_vf(struct e1000_hw *hw, u8 *mc_addr)
  *  The parameter rar_count will usually be hw->mac.rar_entry_count
  *  unless there are workarounds that change this.
  **/
-void e1000_update_mc_addr_list_vf(struct e1000_hw *hw,
+static void e1000_update_mc_addr_list_vf(struct e1000_hw *hw,
                                   u8 *mc_addr_list, u32 mc_addr_count,
                                   u32 rar_used_count, u32 rar_count)
 {
-- 
1.7.4

