From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 2/3] bonding: Remove unnecessary else
Date: Tue, 18 Feb 2014 09:42:46 -0800
Message-ID: <3df50662c3e4dab1f7e97f5f9ad985b5c116bc76.1392745014.git.joe@perches.com>
References: <cover.1392745013.git.joe@perches.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1392745013.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It's unnecessary and less readable after a clause ending in a goto.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/bonding/bond_alb.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 97a43a20..aaeeacf 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1455,12 +1455,12 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 
 		bond_dev_queue_xmit(bond, skb, tx_slave->dev);
 		goto out;
-	} else {
-		if (tx_slave) {
-			_lock_tx_hashtbl(bond);
-			__tlb_clear_slave(bond, tx_slave, 0);
-			_unlock_tx_hashtbl(bond);
-		}
+	}
+
+	if (tx_slave) {
+		_lock_tx_hashtbl(bond);
+		__tlb_clear_slave(bond, tx_slave, 0);
+		_unlock_tx_hashtbl(bond);
 	}
 
 	/* no suitable interface, frame not sent */
-- 
1.8.1.2.459.gbcd45b4.dirty
