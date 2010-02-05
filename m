From: Amit Kucheria <amit.kucheria@canonical.com>
Subject: [PATCH 3/3] fec: Add ARCH_MX5 as a dependency
Date: Fri,  5 Feb 2010 10:56:22 -0800
Message-ID: <05651a6e3d4bb9fc420daa23cabcd12dc2bde961.1265396105.git.amit.kucheria@canonical.com>
References: <cover.1265396105.git.amit.kucheria@canonical.com>
 <39ec69d1e3af809dcf210f4757ca2385efb5f9bc.1265396105.git.amit.kucheria@canonical.com>
 <2b1415552652de10697f5914f0de70dae1c672d4.1265396105.git.amit.kucheria@canonical.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	s.hauer@pengutronix.de, gerg@uclinux.org,
	u.kleine-koenig@pengutronix.de, amit.kucheria@verdurent.com
To: List Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from adelie.canonical.com ([91.189.90.139]:40897 "EHLO
	adelie.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933795Ab0BES4g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2010 13:56:36 -0500
In-Reply-To: <2b1415552652de10697f5914f0de70dae1c672d4.1265396105.git.amit.kucheria@canonical.com>
In-Reply-To: <cover.1265396105.git.amit.kucheria@canonical.com>
References: <cover.1265396105.git.amit.kucheria@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

i.MX51 babbage board has a FEC ethernet controller

Signed-off-by: Amit Kucheria <amit.kucheria@canonical.com>
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

