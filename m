From: Weiping Pan <panweiping3@gmail.com>
Subject: [PATCH net-next 1/2] bonding: delete unused ad_timer
Date: Thu,  9 Jun 2011 10:51:33 +0800
Message-ID: <1d1a90d2f5c7c2ced5eaf8eabffa4fdb770b0e6b.1307587586.git.panweiping3@gmail.com>
References: <cover.1307587586.git.panweiping3@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Weiping Pan <panweiping3@gmail.com>
To: fubar@us.ibm.com, andy@greyhouse.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1307587586.git.panweiping3@gmail.com>
In-Reply-To: <cover.1307587586.git.panweiping3@gmail.com>
References: <cover.1307587586.git.panweiping3@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now we use agg_select_timer and ad_work.

Signed-off-by: Weiping Pan <panweiping3@gmail.com>
---
 drivers/net/bonding/bond_3ad.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.h b/drivers/net/bonding/bond_3ad.h
index 0ee3f16..fb67185 100644
--- a/drivers/net/bonding/bond_3ad.h
+++ b/drivers/net/bonding/bond_3ad.h
@@ -257,7 +257,6 @@ struct ad_bond_info {
 	int lacp_fast;		/* whether fast periodic tx should be
 				 * requested
 				 */
-	struct timer_list ad_timer;
 };
 
 struct ad_slave_info {
-- 
1.7.4.4
