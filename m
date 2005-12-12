From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] drivers/net/bonding/bonding.h: "extern inline" -> "static inline"
Date: Mon, 12 Dec 2005 02:35:26 +0100
Message-ID: <20051212013526.GD23349@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ctindel@users.sourceforge.net, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751002AbVLLBfq@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"extern inline" doesn't make much sense.


Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

This patch was already sent on:
- 18 Nov 2005

 drivers/net/bonding/bonding.h |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

--- linux-2.6.15-rc1-mm1-full/drivers/net/bonding/bonding.h.old	2005-11-18 02:36:37.000000000 +0100
+++ linux-2.6.15-rc1-mm1-full/drivers/net/bonding/bonding.h	2005-11-18 02:37:05.000000000 +0100
@@ -218,7 +218,7 @@
  *
  * Caller must hold bond lock for read
  */
-extern inline struct slave *bond_get_slave_by_dev(struct bonding *bond, struct net_device *slave_dev)
+static inline struct slave *bond_get_slave_by_dev(struct bonding *bond, struct net_device *slave_dev)
 {
 	struct slave *slave = NULL;
 	int i;
@@ -232,7 +232,7 @@
 	return slave;
 }
 
-extern inline struct bonding *bond_get_bond_by_slave(struct slave *slave)
+static inline struct bonding *bond_get_bond_by_slave(struct slave *slave)
 {
 	if (!slave || !slave->dev->master) {
 		return NULL;
@@ -241,13 +241,13 @@
 	return (struct bonding *)slave->dev->master->priv;
 }
 
-extern inline void bond_set_slave_inactive_flags(struct slave *slave)
+static inline void bond_set_slave_inactive_flags(struct slave *slave)
 {
 	slave->state = BOND_STATE_BACKUP;
 	slave->dev->flags |= IFF_NOARP;
 }
 
-extern inline void bond_set_slave_active_flags(struct slave *slave)
+static inline void bond_set_slave_active_flags(struct slave *slave)
 {
 	slave->state = BOND_STATE_ACTIVE;
 	slave->dev->flags &= ~IFF_NOARP;
