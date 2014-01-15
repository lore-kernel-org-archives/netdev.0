From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH v5 net-next 1/4] sh_eth: Use bool as return type of sh_eth_is_gether()
Date: Wed, 15 Jan 2014 15:12:18 +0900
Message-ID: <1389766341-14001-2-git-send-email-horms+renesas@verge.net.au>
References: <1389766341-14001-1-git-send-email-horms+renesas@verge.net.au>
Cc: linux-arm-kernel@lists.infradead.org,
	Magnus Damm <magnus.damm@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Simon Horman <horms+renesas@verge.net.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1389766341-14001-1-git-send-email-horms+renesas@verge.net.au>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Return a boolean and use true and false.

Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

---
v5
* No change

v4
* First post
---
 drivers/net/ethernet/renesas/sh_eth.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index ba1f6c9..4f5cfad 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -310,12 +310,12 @@ static const u16 sh_eth_offset_fast_sh3_sh2[SH_ETH_MAX_REGISTER_OFFSET] = {
 	[TSU_ADRL31]	= 0x01fc,
 };
 
-static int sh_eth_is_gether(struct sh_eth_private *mdp)
+static bool sh_eth_is_gether(struct sh_eth_private *mdp)
 {
 	if (mdp->reg_offset == sh_eth_offset_gigabit)
-		return 1;
+		return true;
 	else
-		return 0;
+		return false;
 }
 
 static void sh_eth_select_mii(struct net_device *ndev)
-- 
1.8.4

