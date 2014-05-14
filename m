From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/2] ti: Remove trailing semicolon from do {...} while (0) macro
Date: Wed, 14 May 2014 12:15:13 -0700
Message-ID: <de49b7a2734337157b439afe30c39e9b40bc6e0f.1400094804.git.joe@perches.com>
References: <cover.1400094804.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1400094804.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These should not have trailing semicolons so remove them.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/ti/cpsw.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index e3d8710..da57d33 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -143,13 +143,13 @@ do {								\
 		u32 i;		\
 		for (i = 0; i < priv->num_irqs; i++) \
 			enable_irq(priv->irqs_table[i]); \
-	} while (0);
+	} while (0)
 #define cpsw_disable_irq(priv)	\
 	do {			\
 		u32 i;		\
 		for (i = 0; i < priv->num_irqs; i++) \
 			disable_irq_nosync(priv->irqs_table[i]); \
-	} while (0);
+	} while (0)
 
 #define cpsw_slave_index(priv)				\
 		((priv->data.dual_emac) ? priv->emac_port :	\
-- 
1.8.1.2.459.gbcd45b4.dirty
