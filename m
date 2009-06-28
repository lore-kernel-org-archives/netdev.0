From: Joe Perches <joe@perches.com>
Subject: [PATCH 29/62] drivers/net/igb/igb_main.c: Remove unnecessary semicolons
Date: Sun, 28 Jun 2009 09:26:34 -0700
Message-ID: <010eef91d631de7860ec1921251c8953fd73dcb5.1246173681.git.joe@perches.com>
References: <cover.1246173664.git.joe@perches.com>
Cc: trivial@kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	John Ronciak <john.ronciak@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:1126 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756474AbZF1Q1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jun 2009 12:27:44 -0400
In-Reply-To: <cover.1246173664.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/igb/igb_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index ea17319..43d5fda 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3901,7 +3901,7 @@ static int igb_set_vf_multicasts(struct igb_adapter *adapter,
 	/* VFs are limited to using the MTA hash table for their multicast
 	 * addresses */
 	for (i = 0; i < n; i++)
-		vf_data->vf_mc_hashes[i] = hash_list[i];;
+		vf_data->vf_mc_hashes[i] = hash_list[i];
 
 	/* Flush and reset the mta with the new values */
 	igb_set_multi(adapter->netdev);
@@ -5447,7 +5447,7 @@ static inline void igb_set_rah_pool(struct e1000_hw *hw, int pool, int entry)
 
 	reg_data = rd32(E1000_RAH(entry));
 	reg_data &= ~E1000_RAH_POOL_MASK;
-	reg_data |= E1000_RAH_POOL_1 << pool;;
+	reg_data |= E1000_RAH_POOL_1 << pool;
 	wr32(E1000_RAH(entry), reg_data);
 }
 
-- 
1.6.3.1.10.g659a0.dirty

