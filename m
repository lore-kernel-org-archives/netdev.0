From: Amit Kucheria <amit.kucheria@canonical.com>
Subject: [PATCHv2 10/11] fec: Add ARCH_MX5 as a dependency
Date: Tue,  2 Feb 2010 21:16:32 -0800
Message-ID: <74c9d000b6fae28d34c5c93116e807c32f49326e.1265173480.git.amit.kucheria@canonical.com>
References: <cover.1265173246.git.amit.kucheria@verdurent.com>
 <0511204199ab83aed2340e70a4639500c0528dab.1265173480.git.amit.kucheria@canonical.com>
 <9fa7a3c70c46a1f776c6520051481cff6525ef02.1265173480.git.amit.kucheria@canonical.com>
 <ccc89dd7a6035abf5a78680404a2b30b9e025353.1265173480.git.amit.kucheria@canonical.com>
 <ec63e5978fd5ac5d308ede5916e648ba925818eb.1265173480.git.amit.kucheria@canonical.com>
 <f10f79e7313ecdeeb59ab881795baedf2430c636.1265173480.git.amit.kucheria@canonical.com>
 <240f12ca87d7666f31263aabc620a9ec197cd8ff.1265173480.git.amit.kucheria@canonical.com>
 <752ae69adb57d4f73fa011ba380cea1b927b9c8b.1265173480.git.amit.kucheria@canonical.com>
 <e46b06510f7eb6ca51ea8b96335b2d32ec8bf6f8.1265173480.git.amit.kucheria@canonical.com>
 <a91f26ae7fc58ea0f88c82f1501e2905fc0f2ab1.1265173480.git.amit.kucheria@canonical.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux@arm.linux.org.uk,
	s.hauer@pengutronix.de, valentin.longchamp@epfl.ch,
	daniel@caiaq.de, grant.likely@secretlab.ca,
	Dinh.Nguyen@freescale.com, r.herring@freescale.com,
	bryan.wu@canonical.com
To: List Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a91f26ae7fc58ea0f88c82f1501e2905fc0f2ab1.1265173480.git.amit.kucheria@canonical.com>
In-Reply-To: <cover.1265173480.git.amit.kucheria@canonical.com>
References: <cover.1265173480.git.amit.kucheria@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

i.MX51 babbage board has a FEC ethernet controller

Signed-off-by: Amit Kucheria <amit.kucheria@canonical.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---
 drivers/net/Kconfig |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index dd9a09c..515658e 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1883,7 +1883,8 @@ config 68360_ENET
 
 config FEC
 	bool "FEC ethernet controller (of ColdFire and some i.MX CPUs)"
-	depends on M523x || M527x || M5272 || M528x || M520x || M532x || MACH_MX27 || ARCH_MX35 || ARCH_MX25
+	depends on M523x || M527x || M5272 || M528x || M520x || M532x || \
+		MACH_MX27 || ARCH_MX35 || ARCH_MX25 || ARCH_MX5
 	help
 	  Say Y here if you want to use the built-in 10/100 Fast ethernet
 	  controller on some Motorola ColdFire and Freescale i.MX processors.
-- 
1.6.3.3
