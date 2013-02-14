From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 0/9] arm-soc/for-next allyesconfig build regressions
Date: Thu, 14 Feb 2013 23:47:42 +0100
Message-ID: <1360882071-4072668-1-git-send-email-arnd@arndb.de>
Cc: linux-kernel@vger.kernel.org, arm@kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Airlie <airlied@redhat.com>,
	Marc Zyngier <marc.zyngier@arm.com>,
	Mark Brown <broonie@opensource.wolfsonmicro.com>,
	Mauro Carvalho Chehab <mchehab@redhat.com>,
	Paul Walmsley <paul@pwsan.com>, Rob Clark <rob@ti.com>,
	Russell King <linux@arm.linux.org.uk>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Shawn Guo <shawn.guo@linaro.org>,
	Tony Lindgren <tony@atomide.com>, netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These are the patches I still need to cleanly build allyesconfig
and allmodconfig on arm-soc/for-next. Please review and provide
Acks where appropriate so we can add the fixes directly to the
branches that introduce the problems, or apply them directly
to a maintainer tree where appropriate.

The bulk of these patches happen to be omap specific, which
does not mean that we had a lot of regressions in omap, but
that we just started including omap in the multiplatform
builds, which has uncovered a number of older problems that
we did not see before.

	Arnd

Arnd Bergmann (9):
  ARM: arch_timer: include linux/errno.h
  ARM: imx: MACH_MX31ADS_WM1133_EV1 needs REGULATOR_WM8350
  ARM: omap2: include linux/errno.h in hwmod_reset
  ARM: omap: add include guard for soc.h
  drm: export drm_vm_open_locked
  net: cwdavinci_cpdma: export symbols for cpsw
  remoteproc: omap: depend on OMAP_MBOX_FWK
  [HACK] ARM: imx: work around v7_cpu_resume link error
  [media] davinci: do not include mach/hardware.h

Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Dave Airlie <airlied@redhat.com>
Cc: Marc Zyngier <marc.zyngier@arm.com>
Cc: Mark Brown <broonie@opensource.wolfsonmicro.com>
Cc: Mauro Carvalho Chehab <mchehab@redhat.com>
Cc: Paul Walmsley <paul@pwsan.com>
Cc: Rob Clark <rob@ti.com>
Cc: Russell King <linux@arm.linux.org.uk>
Cc: Sascha Hauer <s.hauer@pengutronix.de>
Cc: Shawn Guo <shawn.guo@linaro.org>
Cc: Tony Lindgren <tony@atomide.com>
Cc: netdev@vger.kernel.org

 arch/arm/kernel/arch_timer.c            | 1 +
 arch/arm/mach-imx/Kconfig               | 2 +-
 arch/arm/mach-imx/headsmp.S             | 4 +++-
 arch/arm/mach-omap2/omap_hwmod_reset.c  | 1 +
 arch/arm/mach-omap2/soc.h               | 3 +++
 drivers/gpu/drm/drm_vm.c                | 1 +
 drivers/media/platform/davinci/vpss.c   | 1 -
 drivers/net/ethernet/ti/davinci_cpdma.c | 3 +++
 drivers/remoteproc/Kconfig              | 2 +-
 9 files changed, 14 insertions(+), 4 deletions(-)

-- 
1.8.1.2
