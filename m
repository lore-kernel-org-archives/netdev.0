From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 2/2] sh_eth: rename ARSTR register bit
Date: Sun, 24 Apr 2016 23:46:15 +0300
Message-ID: <11425579.ULGl4KSfTY@wasted.cogentembedded.com>
References: <16246598.T4zYgEztZA@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-renesas-soc@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <16246598.T4zYgEztZA@wasted.cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Renesas RZ/A1H manual names the software reset bit in the software reset
register (ARSTR) ARST which makes a bit more sense than the ARSTR_ARSTR name
used now  by the driver -- rename the latter to ARSTR_ARST.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/sh_eth.c |    6 +++---
 drivers/net/ethernet/renesas/sh_eth.h |    2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -482,7 +482,7 @@ static void sh_eth_chip_reset(struct net
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 
 	/* reset device */
-	sh_eth_tsu_write(mdp, ARSTR_ARSTR, ARSTR);
+	sh_eth_tsu_write(mdp, ARSTR_ARST, ARSTR);
 	mdelay(1);
 }
 
@@ -540,7 +540,7 @@ static void sh_eth_chip_reset_r8a7740(st
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 
 	/* reset device */
-	sh_eth_tsu_write(mdp, ARSTR_ARSTR, ARSTR);
+	sh_eth_tsu_write(mdp, ARSTR_ARST, ARSTR);
 	mdelay(1);
 
 	sh_eth_select_mii(ndev);
@@ -735,7 +735,7 @@ static void sh_eth_chip_reset_giga(struc
 	}
 
 	/* reset device */
-	iowrite32(ARSTR_ARSTR, (void *)(SH_GIGA_ETH_BASE + 0x1800));
+	iowrite32(ARSTR_ARST, (void *)(SH_GIGA_ETH_BASE + 0x1800));
 	mdelay(1);
 
 	/* restore MAHR and MALR */
Index: net-next/drivers/net/ethernet/renesas/sh_eth.h
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.h
+++ net-next/drivers/net/ethernet/renesas/sh_eth.h
@@ -394,7 +394,7 @@ enum RPADIR_BIT {
 #define DEFAULT_FDR_INIT	0x00000707
 
 /* ARSTR */
-enum ARSTR_BIT { ARSTR_ARSTR = 0x00000001, };
+enum ARSTR_BIT { ARSTR_ARST = 0x00000001, };
 
 /* TSU_FWEN0 */
 enum TSU_FWEN0_BIT {
