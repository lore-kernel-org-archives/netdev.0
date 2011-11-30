From: Fabio Estevam <fabio.estevam@freescale.com>
Subject: [PATCH v3] net: fec: Select the FEC driver by default for i.MX SoCs
Date: Wed, 30 Nov 2011 12:42:18 -0200
Message-ID: <1322664138-3245-1-git-send-email-fabio.estevam@freescale.com>
References: <1322652717-2685-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0337180682594616792=="
Cc: Fabio Estevam <fabio.estevam@freescale.com>, netdev@vger.kernel.org,
 marek.vasut@gmail.com, kernel@pengutronix.de, u.kleine-koenig@pengutronix.de,
 davem@davemloft.net, shawn.guo@freescale.com
To: <linux-arm-kernel@lists.infradead.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1322652717-2685-1-git-send-email-fabio.estevam@freescale.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

--===============0337180682594616792==
Content-Type: text/plain

Since commit 230dec6 (net/fec: add imx6q enet support) the FEC driver is no 
longer built by default for i.MX SoCs.

Let the FEC driver be built by default again.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
Suggested-by: Uwe Kleine-König <u.kleine-koenig@pengutronix.de>
Acked-by: Uwe Kleine-König <u.kleine-koenig@pengutronix.de
Acked-by: Shawn Guo <shawn.guo@linaro.org>
---
Changes since v2:
- Improve commit message
- Reorder the placement of the "default" line
Changes since v1: 
Move the FEC selection into Kconfig instead of .config file
 drivers/net/ethernet/freescale/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/freescale/Kconfig b/drivers/net/ethernet/freescale/Kconfig
index c520cfd..5272f9d 100644
--- a/drivers/net/ethernet/freescale/Kconfig
+++ b/drivers/net/ethernet/freescale/Kconfig
@@ -24,6 +24,7 @@ config FEC
 	bool "FEC ethernet controller (of ColdFire and some i.MX CPUs)"
 	depends on (M523x || M527x || M5272 || M528x || M520x || M532x || \
 		   ARCH_MXC || ARCH_MXS)
+	default ARCH_MXC || ARCH_MXS if ARM
 	select PHYLIB
 	---help---
 	  Say Y here if you want to use the built-in 10/100 Fast ethernet
-- 
1.7.1




--===============0337180682594616792==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
linux-arm-kernel mailing list
linux-arm-kernel@lists.infradead.org
http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

--===============0337180682594616792==--
