From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH] net: dsa: mv88e6xxx: make irq_chip const
Date: Sat, 19 Aug 2017 16:25:52 +0530
Message-ID: <1503140152-7719-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make this const as it is only used in a copy operation.
Done using Coccinelle.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c    | 2 +-
 drivers/net/dsa/mv88e6xxx/global2.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 918d8f0..c6678aa 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -307,7 +307,7 @@ static void mv88e6xxx_g1_irq_bus_sync_unlock(struct irq_data *d)
 	mutex_unlock(&chip->reg_lock);
 }
 
-static struct irq_chip mv88e6xxx_g1_irq_chip = {
+static const struct irq_chip mv88e6xxx_g1_irq_chip = {
 	.name			= "mv88e6xxx-g1",
 	.irq_mask		= mv88e6xxx_g1_irq_mask,
 	.irq_unmask		= mv88e6xxx_g1_irq_unmask,
diff --git a/drivers/net/dsa/mv88e6xxx/global2.c b/drivers/net/dsa/mv88e6xxx/global2.c
index 16f5562..af07278 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.c
+++ b/drivers/net/dsa/mv88e6xxx/global2.c
@@ -1019,7 +1019,7 @@ static void mv88e6xxx_g2_irq_bus_sync_unlock(struct irq_data *d)
 	mutex_unlock(&chip->reg_lock);
 }
 
-static struct irq_chip mv88e6xxx_g2_irq_chip = {
+static const struct irq_chip mv88e6xxx_g2_irq_chip = {
 	.name			= "mv88e6xxx-g2",
 	.irq_mask		= mv88e6xxx_g2_irq_mask,
 	.irq_unmask		= mv88e6xxx_g2_irq_unmask,
-- 
1.9.1
