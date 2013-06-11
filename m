From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] sh_eth: remove '__maybe_unused' annotations
Date: Wed, 12 Jun 2013 03:07:29 +0400
Message-ID: <201306120307.29615.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that  the SoC specific support is no longer done with help of #ifdef'fery,
we  no longer need '__maybe_unused' annotations to sh_eth_select_mii() and
sh_eth_set_duplex()...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against Dave Miller's 'net-next.git' repo.

 drivers/net/ethernet/renesas/sh_eth.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -321,7 +321,7 @@ static int sh_eth_is_gether(struct sh_et
 		return 0;
 }
 
-static void __maybe_unused sh_eth_select_mii(struct net_device *ndev)
+static void sh_eth_select_mii(struct net_device *ndev)
 {
 	u32 value = 0x0;
 	struct sh_eth_private *mdp = netdev_priv(ndev);
@@ -345,7 +345,7 @@ static void __maybe_unused sh_eth_select
 	sh_eth_write(ndev, value, RMII_MII);
 }
 
-static void __maybe_unused sh_eth_set_duplex(struct net_device *ndev)
+static void sh_eth_set_duplex(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 
