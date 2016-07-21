From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH] net: bridge: fix br_stp_enable_bridge comment
Date: Thu, 21 Jul 2016 12:42:10 -0400
Message-ID: <20160721164210.26662-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

br_stp_enable_bridge() does take the br->lock spinlock. Fix its wrongly
pasted comment and use the same as br_stp_disable_bridge().

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/bridge/br_stp_if.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
index 984d462..341caa0 100644
--- a/net/bridge/br_stp_if.c
+++ b/net/bridge/br_stp_if.c
@@ -55,7 +55,7 @@ void br_init_port(struct net_bridge_port *p)
 		netdev_err(p->dev, "failed to set HW ageing time\n");
 }
 
-/* called under bridge lock */
+/* NO locks held */
 void br_stp_enable_bridge(struct net_bridge *br)
 {
 	struct net_bridge_port *p;
-- 
2.9.0
