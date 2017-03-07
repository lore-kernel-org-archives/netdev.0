From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCHv3 net-next 22/22] net: mvpp2: finally add the PPv2.2
 compatible string
Date: Tue,  7 Mar 2017 16:53:20 +0100
Message-ID: <1488902000-2658-23-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1488902000-2658-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 Andrew Lunn <andrew@lunn.ch>, Yehuda Yitschak <yehuday@marvell.com>,
 Russell King <linux@arm.linux.org.uk>, Jason Cooper <jason@lakedaemon.net>,
 Hanna Hawa <hannah@marvell.com>, Nadav Haklai <nadavh@marvell.com>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Stefan Chulski <stefanc@marvell.com>, Marcin Wojtas <mw@semihalf.com>,
 linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
 devicetree@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
 Ian Campbell <ijc+devicetree@hellion.org.uk>,
 Pawel Moll <pawel.moll@arm.com>, Mark Rutland <mark.rutland@arm.com>,
 Kumar Gala <galak@codeaurora.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1488902000-2658-1-git-send-email-thomas.petazzoni@free-electrons.com>
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

Now that the mvpp2 driver has been modified to accommodate the support
for PPv2.2, we can finally advertise this support by adding the
appropriate compatible string.

At the same time, we update the Kconfig description of the MVPP2 driver.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/Kconfig | 4 ++--
 drivers/net/ethernet/marvell/mvpp2.c | 4 ++++
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/Kconfig b/drivers/net/ethernet/marvell/Kconfig
index d2555e8b..da6fb82 100644
--- a/drivers/net/ethernet/marvell/Kconfig
+++ b/drivers/net/ethernet/marvell/Kconfig
@@ -82,13 +82,13 @@ config MVNETA_BM
 	  that all dependencies are met.
 
 config MVPP2
-	tristate "Marvell Armada 375 network interface support"
+	tristate "Marvell Armada 375/7K/8K network interface support"
 	depends on ARCH_MVEBU || COMPILE_TEST
 	depends on HAS_DMA
 	select MVMDIO
 	---help---
 	  This driver supports the network interface units in the
-	  Marvell ARMADA 375 SoC.
+	  Marvell ARMADA 375, 7K and 8K SoCs.
 
 config PXA168_ETH
 	tristate "Marvell pxa168 ethernet support"
diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 92c47f3..af5bfa1 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -7037,6 +7037,10 @@ static const struct of_device_id mvpp2_match[] = {
 		.compatible = "marvell,armada-375-pp2",
 		.data = (void *)MVPP21,
 	},
+	{
+		.compatible = "marvell,armada-7k-pp22",
+		.data = (void *)MVPP22,
+	},
 	{ }
 };
 MODULE_DEVICE_TABLE(of, mvpp2_match);
-- 
2.7.4
