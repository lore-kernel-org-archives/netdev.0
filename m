From: Pai <vpai@akamai.com>
Subject: [PATCH net] net/bonding: Fix code style issues in a previous commit
Date: Wed, 29 Apr 2015 20:01:27 -0400
Message-ID: <E1Ynbux-0004Zy-Jn@bos-lpqrs.kendall.corp.akamai.com>
To: "Nikolay Aleksandrov" <razor@blackwall.org>,
	"Jay Vosburgh" <j.vosburgh@gmail.com>,
	"Veaceslav Falico" <vfalico@gmail.com>,
	"Andy Gospodarek" <andy@greyhouse.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, "Vishwanath Pai" <vpai@akamai.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes a few coding style issues in my previous patch:
commit e913fb279c56
("net: Fix Kernel Panic in bonding driver debugfs file: rlb_hash_table")

Signed-off-by: Vishwanath Pai <vpai@akamai.com>

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index d5fe5d5..ab3eeb1 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4543,8 +4543,8 @@ unsigned int bond_get_num_tx_queues(void)
  */
 int bond_create(struct net *net, const char *name)
 {
-	struct net_device *bond_dev;
 	struct bonding *bond;
+	struct net_device *bond_dev;
 	struct alb_bond_info *bond_info;
 	int res;
 
@@ -4559,8 +4559,7 @@ int bond_create(struct net *net, const char *name)
 		return -ENOMEM;
 	}
 
-	/*
-	 * Initialize rx_hashtbl_used_head to RLB_NULL_INDEX.
+	/* Initialize rx_hashtbl_used_head to RLB_NULL_INDEX.
 	 * It is set to 0 by default which is wrong.
 	 */
 	bond = netdev_priv(bond_dev);
