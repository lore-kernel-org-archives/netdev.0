From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] net: remove remaining fastcall occurances in drivers/net
Date: Wed, 12 Dec 2007 12:48:09 -0800
Message-ID: <1197492489.21291.21.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>
To: linux-netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758751AbXLLUsW@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

fastcall is always defined to empty, remove it

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 drivers/net/ns83820.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ns83820.c b/drivers/net/ns83820.c
index 972acc3..5eed99e 100644
--- a/drivers/net/ns83820.c
+++ b/drivers/net/ns83820.c
@@ -612,7 +612,7 @@ static inline int rx_refill(struct net_device *ndev, gfp_t gfp)
 }
 
 static void rx_refill_atomic(struct net_device *ndev));
-static void fastcall rx_refill_atomic(struct net_device *ndev)
+static void rx_refill_atomic(struct net_device *ndev)
 {
 	rx_refill(ndev, GFP_ATOMIC);
 }
@@ -633,7 +633,7 @@ static inline void clear_rx_desc(struct ns83820 *dev, unsigned i)
 	build_rx_desc(dev, dev->rx_info.descs + (DESC_SIZE * i), 0, 0, CMDSTS_OWN, 0);
 }
 
-static void fastcall phy_intr(struct net_device *ndev)
+static void phy_intr(struct net_device *ndev)
 {
 	struct ns83820 *dev = PRIV(ndev);
 	static const char *speeds[] = { "10", "100", "1000", "1000(?)", "1000F" };
@@ -831,7 +831,7 @@ static void ns83820_cleanup_rx(struct ns83820 *dev)
 	}
 }
 
-static void fastcall ns83820_rx_kick(struct net_device *ndev)
+static void ns83820_rx_kick(struct net_device *ndev)
 {
 	struct ns83820 *dev = PRIV(ndev);
 	/*if (nr_rx_empty(dev) >= NR_RX_DESC/4)*/ {
@@ -852,7 +852,7 @@ static void fastcall ns83820_rx_kick(struct net_device *ndev)
 /* rx_irq
  *
  */
-static void fastcall rx_irq(struct net_device *ndev)
+static void rx_irq(struct net_device *ndev)
 {
 	struct ns83820 *dev = PRIV(ndev);
 	struct rx_info *info = &dev->rx_info;
-- 
1.5.3.7.2212.gd092



