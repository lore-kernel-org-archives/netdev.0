From: Adrian Bunk <bunk@fs.tum.de>
Subject: [patch] 2.5.73-mm2: let CONFIG_TC35815 depend on CONFIG_TOSHIBA_JMR3927
Date: Sun, 29 Jun 2003 21:04:32 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030629190431.GB282__48197.3465918147$1056916612@fs.tum.de>
References: <20030627202130.066c183b.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, trivial@rustcorp.com.au
Return-path: <netdev-bounce@oss.sgi.com>
Resent-Message-ID: <20030629195459.13390.qmail@mimas>
To: Andrew Morton <akpm@digeo.com>, ralf@linux-mips.org
Content-Disposition: inline
In-Reply-To: <20030627202130.066c183b.akpm@digeo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The following problem seems to come from Linus' tree:

I got an error at the final linking with CONFIG_TC35815 enabled since
the variables tc_readl and tc_writel are not available.

The only place where they are defined is arch/mips/pci/ops-jmr3927.c, so 
I assume the following was intended:


--- linux-2.5.73-mm2/drivers/net/Kconfig.old	2003-06-28 11:14:16.000000000 +0200
+++ linux-2.5.73-mm2/drivers/net/Kconfig	2003-06-29 20:55:16.000000000 +0200
@@ -1397,7 +1397,7 @@
 
 config TC35815
 	tristate "TOSHIBA TC35815 Ethernet support"
-	depends on NET_PCI && PCI
+	depends on NET_PCI && PCI && TOSHIBA_JMR3927
 
 config DGRS
 	tristate "Digi Intl. RightSwitch SE-X support"


cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

