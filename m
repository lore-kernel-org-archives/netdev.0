From: Richard Zhao <richard.zhao@linaro.org>
Subject: [PATCH V4 00/14] add clk_prepare/clk_unprepare to imx drivers
Date: Tue, 15 Nov 2011 14:47:55 +0800
Message-ID: <1321339689-25256-1-git-send-email-richard.zhao@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux@arm.linux.org.uk>, <amit.kucheria@canonical.com>,
	<kernel@pengutronix.de>, <ben-linux@fluff.org>, <cjb@laptop.org>,
	<alan@linux.intel.com>, <eric.miao@linaro.org>,
	<richard.zhao@linaro.org>
To: <linux-arm-kernel@lists.infradead.org>,
	<linux-i2c@vger.kernel.org>, <linux-mmc@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-serial@vger.kernel.org>
Return-path: <linux-serial-owner@vger.kernel.org>
Sender: linux-serial-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Changes since V3:
 - add more comments

Changes since V2:
 - fix clk_prepare_enable bug

Changes since V1:
 - Add common helper functions clk_prepare_enable/clk_disable_unprepare
 - serial/imx: move clk_disable_unprepare before clk_put


Richard Zhao (14):
      clk: add helper functions clk_prepare_enable and clk_disable_unprepare
      ARM: mxc: time: add clk_prepare/clk_unprepare
      ARM: mxc: ahci: add clk_prepare/clk_unprepare
      ARM: mxc: pwm: add clk_prepare/clk_unprepare
      ARM: mxc: epit: add clk_prepare/clk_unprepare
      ARM: mxc: arch_reset: add clk_prepare/clk_unprepare
      ARM: mxc: audmux-v2: add clk_prepare/clk_unprepare
      ARM: pm-imx5: add clk_prepare/clk_unprepare
      ARM: mx31moboard: add clk_prepare/clk_unprepare
      ARM: mxs: add clk_prepare/clk_unprepare
      serial: imx: add clk_prepare/clk_unprepare
      net: fec: add clk_prepare/clk_unprepare
      i2c: imx: add clk_prepare/clk_unprepare
      mmc: sdhci-esdhc-imx: add clk_prepare/clk_unprepare

 arch/arm/mach-imx/mach-mx31moboard.c          |    2 +-
 arch/arm/mach-mx5/pm-imx5.c                   |    4 ++--
 arch/arm/mach-mxs/system.c                    |    2 +-
 arch/arm/mach-mxs/timer.c                     |    2 +-
 arch/arm/plat-mxc/audmux-v2.c                 |    8 ++++----
 arch/arm/plat-mxc/devices/platform-ahci-imx.c |   16 ++++++++--------
 arch/arm/plat-mxc/epit.c                      |    2 +-
 arch/arm/plat-mxc/pwm.c                       |    4 ++--
 arch/arm/plat-mxc/system.c                    |    2 +-
 arch/arm/plat-mxc/time.c                      |    2 +-
 drivers/i2c/busses/i2c-imx.c                  |    4 ++--
 drivers/mmc/host/sdhci-esdhc-imx.c            |    6 +++---
 drivers/net/ethernet/freescale/fec.c          |   10 +++++-----
 drivers/tty/serial/imx.c                      |    7 +++----
 include/linux/clk.h                           |   22 ++++++++++++++++++++++
 15 files changed, 57 insertions(+), 36 deletions(-)


Thanks
Richard


