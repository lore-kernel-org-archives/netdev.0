From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH v6 6/7] ARM: kirkwood: remove legacy clk alias for mv643xx_eth
Date: Tue,  2 Jul 2013 13:00:23 +0200
Message-ID: <1372762824-12202-7-git-send-email-sebastian.hesselbarth@gmail.com>
References: <1372762824-12202-1-git-send-email-sebastian.hesselbarth@gmail.com>
Cc: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Russell King <linux@arm.linux.org.uk>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1372762824-12202-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With all boards converted to DT enabled mv643xx_eth we can now
remove the clock alias for gbe clocks.

Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
---
Changelog:
v5->v6:
- rebase for v3.11-rc1

Cc: Russell King <linux@arm.linux.org.uk>
Cc: Jason Cooper <jason@lakedaemon.net>
Cc: Andrew Lunn <andrew@lunn.ch>
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Cc: Gregory CLEMENT <gregory.clement@free-electrons.com>
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org
---
 arch/arm/mach-kirkwood/board-dt.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/arch/arm/mach-kirkwood/board-dt.c b/arch/arm/mach-kirkwood/board-dt.c
index a3271f6..881f37e 100644
--- a/arch/arm/mach-kirkwood/board-dt.c
+++ b/arch/arm/mach-kirkwood/board-dt.c
@@ -60,12 +60,10 @@ static void __init kirkwood_legacy_clk_init(void)
 	 */
 	clkspec.args[0] = CGC_BIT_GE0;
 	clk = of_clk_get_from_provider(&clkspec);
-	orion_clkdev_add(NULL, "mv643xx_eth_port.0", clk);
 	clk_prepare_enable(clk);
 
 	clkspec.args[0] = CGC_BIT_GE1;
 	clk = of_clk_get_from_provider(&clkspec);
-	orion_clkdev_add(NULL, "mv643xx_eth_port.1", clk);
 	clk_prepare_enable(clk);
 }
 
-- 
1.7.2.5
