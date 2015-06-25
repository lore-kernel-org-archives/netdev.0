From: Alison Wang <b18965@freescale.com>
Subject: [PATCH] net/fsl: remove dependency FSL_SOC for Gianfar
Date: Thu, 25 Jun 2015 11:34:38 +0800
Message-ID: <1435203278-40383-1-git-send-email-b18965@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Alison Wang <alison.wang@freescale.com>
To: davem@davemloft.net, jeffrey.t.kirsher@intel.com, ogerlitz@mellanox.com,
 hariprasad@chelsio.com, claudiu.manoil@freescale.com,
 shawn.guo@linaro.org, jason.jin@freescale.com, netdev@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

CONFIG_GIANFAR is not depended on FSL_SOC, it
can be built on non-PPC platforms.

Signed-off-by: Alison Wang <alison.wang@freescale.com>
---
 drivers/net/ethernet/freescale/Kconfig | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/Kconfig b/drivers/net/ethernet/freescale/Kconfig
index b8de87b..ff76d4e 100644
--- a/drivers/net/ethernet/freescale/Kconfig
+++ b/drivers/net/ethernet/freescale/Kconfig
@@ -83,12 +83,12 @@ config UGETH_TX_ON_DEMAND
 
 config GIANFAR
 	tristate "Gianfar Ethernet"
-	depends on FSL_SOC
 	select FSL_PQ_MDIO
 	select PHYLIB
 	select CRC32
 	---help---
 	  This driver supports the Gigabit TSEC on the MPC83xx, MPC85xx,
-	  and MPC86xx family of chips, and the FEC on the 8540.
+	  and MPC86xx family of chips, the eTSEC on LS1021A and the FEC
+	  on the 8540.
 
 endif # NET_VENDOR_FREESCALE
-- 
2.1.0.27.g96db324
