From: Masahiro Yamada <yamada.m@jp.panasonic.com>
Subject: [PATCH 0/3] kbuild: Clean up makefiles and then drop obj-n an obj-n
Date: Tue,  9 Sep 2014 19:26:18 +0900
Message-ID: <1410258381-7088-1-git-send-email-yamada.m@jp.panasonic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Ben Dooks <ben-linux@fluff.org>, Tony Lindgren <tony@atomide.com>,
 Linus Walleij <linus.walleij@linaro.org>,
 Nicolas Ferre <nicolas.ferre@atmel.com>,
 Takashi Yoshii <takasi-y@ops.dti.ne.jp>,
 Wolfram Sang <wsa@sang-engineering.com>, Greg Ungerer <gerg@uclinux.org>,
 Kukjin Kim <kgene.kim@samsung.com>, Sam Ravnborg <sam@ravnborg.org>,
 Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>,
 Mike Turquette <mturquette@linaro.org>,
 Geert Uytterhoeven <geert@linux-m68k.org>,
 Russell King <linux@arm.linux.org.uk>,
 Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
 linux-samsung-soc@vger.kernel.org, Ulrich Hecht <ulrich.hecht@gmail.com>,
 Simon Horman <horms+renesas@verge.net.au>, linux-omap@vger.kernel.org,
 Andrew Victor <linux@maxim.org.za>, linux-arm-kernel@lists.infradead.org,
 Michal Marek <mmarek@suse.cz>, Ryan Mallon <rmallon@gmail.com>,
 netdev@vger.kernel.org
To: linux-kbuild@vger.kernel.org
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




Masahiro Yamada (3):
  kbuild: remove unnecessary "obj- := dummy.o" trick
  kbuild: remove unnecessary variable initializaions
  kbuild: remove obj-n and lib-n handling

 arch/arm/mach-at91/Makefile       | 3 ---
 arch/arm/mach-ebsa110/Makefile    | 3 ---
 arch/arm/mach-ep93xx/Makefile     | 3 ---
 arch/arm/mach-exynos/Makefile     | 5 -----
 arch/arm/mach-footbridge/Makefile | 3 ---
 arch/arm/mach-iop13xx/Makefile    | 5 -----
 arch/arm/mach-iop32x/Makefile     | 3 ---
 arch/arm/mach-iop33x/Makefile     | 3 ---
 arch/arm/mach-ks8695/Makefile     | 3 ---
 arch/arm/mach-rpc/Makefile        | 4 ----
 arch/arm/mach-s3c24xx/Makefile    | 5 -----
 arch/arm/mach-s3c64xx/Makefile    | 5 -----
 arch/arm/mach-s5pv210/Makefile    | 5 -----
 arch/arm/mach-sa1100/Makefile     | 3 ---
 arch/arm/mach-u300/Makefile       | 3 ---
 arch/arm/plat-iop/Makefile        | 6 ------
 arch/arm/plat-omap/Makefile       | 3 ---
 arch/arm/plat-samsung/Makefile    | 5 -----
 drivers/clk/shmobile/Makefile     | 2 --
 drivers/net/wimax/Makefile        | 4 ----
 firmware/Makefile                 | 2 +-
 scripts/Makefile.build            | 4 ++--
 scripts/Makefile.clean            | 4 +---
 scripts/Makefile.fwinst           | 2 +-
 24 files changed, 5 insertions(+), 83 deletions(-)

-- 
1.9.1
