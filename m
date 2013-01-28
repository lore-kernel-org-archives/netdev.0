From: Prabhakar Lad <prabhakar.csengg@gmail.com>
Subject: [PATCH v2 5/6] ARM: davinci: da850: add OF_DEV_AUXDATA entry for eth0.
Date: Mon, 28 Jan 2013 19:17:58 +0530
Message-ID: <1359380879-26306-6-git-send-email-prabhakar.lad@ti.com>
References: <1359380879-26306-1-git-send-email-prabhakar.lad@ti.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org, Heiko Schocher <hs@denx.de>,
	"Lad, Prabhakar" <prabhakar.lad@ti.com>
To: Sekhar Nori <nsekhar@ti.com>, linux-arm-kernel@lists.infradead.org,
	davinci-linux-open-source@linux.davincidsp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1359380879-26306-1-git-send-email-prabhakar.lad@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lad, Prabhakar <prabhakar.lad@ti.com>

Add OF_DEV_AUXDATA for eth0  driver in da850 board dt
file to use emac clock.

Signed-off-by: Lad, Prabhakar <prabhakar.lad@ti.com>
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
Cc: davinci-linux-open-source@linux.davincidsp.com
Cc: netdev@vger.kernel.org
Cc: devicetree-discuss@lists.ozlabs.org
Cc: Sekhar Nori <nsekhar@ti.com>
Cc: Heiko Schocher <hs@denx.de>
---
 arch/arm/mach-davinci/da8xx-dt.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/arch/arm/mach-davinci/da8xx-dt.c b/arch/arm/mach-davinci/da8xx-dt.c
index bd00042..e533a0a 100644
--- a/arch/arm/mach-davinci/da8xx-dt.c
+++ b/arch/arm/mach-davinci/da8xx-dt.c
@@ -41,6 +41,8 @@ static void __init da8xx_init_irq(void)
 
 struct of_dev_auxdata da8xx_auxdata[] __initdata = {
 	OF_DEV_AUXDATA("ti,davinci_mdio", 0x01e24000, "davinci_mdio.0", NULL),
+	OF_DEV_AUXDATA("ti,davinci-dm6467-emac", 0x01e20000, "davinci_emac.1",
+		       NULL),
 	{},
 };
 
-- 
1.7.4.1
