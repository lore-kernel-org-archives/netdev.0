From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the omap tree
Date: Mon, 27 Sep 2010 14:29:15 +1000
Message-ID: <20100927142915.081bbf24.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sukumar Ghorai <s-ghorai@ti.com>,
	Tony Lindgren <tony@atomide.com>, <linux-omap@vger.kernel.org>,
	"Ohad Ben-Cohen" <ohad@wizery.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in
arch/arm/mach-omap2/board-zoom-peripherals.c between commit
6db649c505ddc6665176807c16745b9e01cf5031 ("omap: mmc: extended to pass
host capabilities from board file") from the omap tree and commits
b642fde7f137566c993991fd2e7bf6b8274bf625 ("omap: zoom: add fixed
regulator device for wlan") and 80b517f362605f2b6a6cfe086604534290aab2de
("omap: zoom: add mmc3/wl1271 device support") from the net tree.

Just overlapping additions.  I fixed it up (see below) and can carry the
fix as necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc arch/arm/mach-omap2/board-zoom-peripherals.c
index e5eac46,6aa0728..0000000
--- a/arch/arm/mach-omap2/board-zoom-peripherals.c
+++ b/arch/arm/mach-omap2/board-zoom-peripherals.c
@@@ -16,7 -16,8 +16,9 @@@
  #include <linux/gpio.h>
  #include <linux/i2c/twl.h>
  #include <linux/regulator/machine.h>
 +#include <linux/mmc/host.h>
+ #include <linux/regulator/fixed.h>
+ #include <linux/wl12xx.h>
  
  #include <asm/mach-types.h>
  #include <asm/mach/arch.h>
