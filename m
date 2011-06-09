From: Weiping Pan <panweiping3@gmail.com>
Subject: [PATCH net-next 4/5] bonding: delete unused ad_timer
Date: Thu,  9 Jun 2011 15:19:04 +0800
Message-ID: <5fd74a13b14c3bd39f6f033dc0ddc48fb9c2c3b6.1307603621.git.panweiping3@gmail.com>
References: <cover.1307603621.git.panweiping3@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Weiping Pan <panweiping3@gmail.com>
To: fubar@us.ibm.com, andy@greyhouse.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1307603621.git.panweiping3@gmail.com>
In-Reply-To: <cover.1307603621.git.panweiping3@gmail.com>
References: <cover.1307603621.git.panweiping3@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now we use agg_select_timer and ad_work.

Reviewed-by: WANG Cong <xiyou.wangcong@gmail.com>
Signed-off-by: Weiping Pan <panweiping3@gmail.com>
---
 drivers/net/bonding/bond_3ad.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.h b/drivers/net/bonding/bond_3ad.h
index 1682e69..235b2cc 100644
--- a/drivers/net/bonding/bond_3ad.h
+++ b/drivers/net/bonding/bond_3ad.h
@@ -253,7 +253,6 @@ struct ad_system {
 struct ad_bond_info {
 	struct ad_system system;	    /* 802.3ad system structure */
 	u32 agg_select_timer;	    // Timer to select aggregator after all adapter's hand shakes
-	struct timer_list ad_timer;
 };
 
 struct ad_slave_info {
-- 
1.7.4.4
