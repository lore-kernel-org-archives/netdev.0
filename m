From: David Daney <ddaney.cavm@gmail.com>
Subject: [PATCH 7/8] netdev: octeon_mgmt: Remove some useless 'inline'
Date: Tue, 21 Aug 2012 11:45:11 -0700
Message-ID: <1345574712-21444-8-git-send-email-ddaney.cavm@gmail.com>
References: <1345574712-21444-1-git-send-email-ddaney.cavm@gmail.com>
Cc: linux-kernel@vger.kernel.org, David Daney <david.daney@cavium.com>
To: linux-mips@linux-mips.org, ralf@linux-mips.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1345574712-21444-1-git-send-email-ddaney.cavm@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Daney <david.daney@cavium.com>

Signed-off-by: David Daney <david.daney@cavium.com>
---
 drivers/net/ethernet/octeon/octeon_mgmt.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/octeon/octeon_mgmt.c b/drivers/net/ethernet/octeon/octeon_mgmt.c
index 9b526da..ccb1f81 100644
--- a/drivers/net/ethernet/octeon/octeon_mgmt.c
+++ b/drivers/net/ethernet/octeon/octeon_mgmt.c
@@ -173,22 +173,22 @@ static void octeon_mgmt_set_tx_irq(struct octeon_mgmt *p, int enable)
 	spin_unlock_irqrestore(&p->lock, flags);
 }
 
-static inline void octeon_mgmt_enable_rx_irq(struct octeon_mgmt *p)
+static void octeon_mgmt_enable_rx_irq(struct octeon_mgmt *p)
 {
 	octeon_mgmt_set_rx_irq(p, 1);
 }
 
-static inline void octeon_mgmt_disable_rx_irq(struct octeon_mgmt *p)
+static void octeon_mgmt_disable_rx_irq(struct octeon_mgmt *p)
 {
 	octeon_mgmt_set_rx_irq(p, 0);
 }
 
-static inline void octeon_mgmt_enable_tx_irq(struct octeon_mgmt *p)
+static void octeon_mgmt_enable_tx_irq(struct octeon_mgmt *p)
 {
 	octeon_mgmt_set_tx_irq(p, 1);
 }
 
-static inline void octeon_mgmt_disable_tx_irq(struct octeon_mgmt *p)
+static void octeon_mgmt_disable_tx_irq(struct octeon_mgmt *p)
 {
 	octeon_mgmt_set_tx_irq(p, 0);
 }
-- 
1.7.11.4
