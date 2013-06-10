From: Tushar Behera <tushar.behera@linaro.org>
Subject: [PATCH 00/15] Convert to use devm_ioremap_resource
Date: Mon, 10 Jun 2013 17:04:58 +0530
Message-ID: <1370864113-17895-1-git-send-email-tushar.behera@linaro.org>
Cc: thierry.reding@gmail.com, patches@linaro.org,
	alsa-devel@alsa-project.org, devel@driverdev.osuosl.org,
	linux-can@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-gpio@vger.kernel.org, linux-mmc@vger.kernel.org,
	linux-pci@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, sparclinux@vger.kernel.org,
	Bjorn Helgaas <bhelgaas@google.com>,
	Chris Ball <cjb@laptop.org>, Dan Williams <djbw@fb.com>,
	"David S. Miller" <davem@davemloft.net>,
	Felipe Balbi <balbi@ti.com>,
	Grant Likely <grant.likely@linaro.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Liam Girdwood <lgirdwood@gmail.com>,
	Linus Walleij <linus.walleij@linaro.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Mark Brown <broonie@kernel.org>,
	Michal Simek <michal.simek@xilinx.com>,
	Rob Landley <rob@landley.net>,
	Vinod Koul <vinod.koul@intel.com>,
	Wolfgang Grandegger <wg@grandegger.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These are the remaining instances of devm_request_and_ioremap. Convert
them to use devm_ioremap_resource as introduced by commit
75096579c3ac ("lib: devres: Introduce devm_ioremap_resource()).
Patches 1 to 13 remove occurrences of devm_request_and_ioremap.
Patch 14 modifies one comment that speaks about devm_request_and_ioremap.
Patch 15 removes the definition of devm_request_and_ioremap which
should only be applied if all other pathces are merged.

Tushar Behera (15):
  sparc,leon: Convert to use devm_ioremap_resource
  sudmac: Convert to use devm_ioremap_resource
  mmc: mvsdio: Convert to use devm_ioremap_resource
  gpio_msm: Convert to use devm_ioremap_resource
  gpio-sta2x11: Convert to use devm_ioremap_resource
  net: bcm63xx_enet: Convert to use devm_ioremap_resource
  net: fec: Convert to use devm_ioremap_resource
  net: emaclite: Convert to use devm_ioremap_resource
  net: can: Convert to use devm_ioremap_resource
  Staging: netlogic: Convert to use devm_ioremap_resource
  regulator: ti-abb: Convert to use devm_ioremap_resource
  ASoC: spear: Convert to use devm_ioremap_resource
  pci: mvebu: Convert to use devm_ioremap_resource
  usb: phy: rcar-usb: Fix comment w.r.t. devm_ioremap_resource
  lib: devres: Remove deprecated devm_request_and_ioremap

 Documentation/driver-model/devres.txt         |    1 -
 arch/sparc/kernel/leon_pci_grpci1.c           |    6 +++---
 drivers/dma/sh/sudmac.c                       |    6 +++---
 drivers/gpio/gpio-msm-v1.c                    |   12 +++++------
 drivers/gpio/gpio-sta2x11.c                   |    4 +++-
 drivers/mmc/host/mvsdio.c                     |    6 +++---
 drivers/net/can/c_can/c_can_platform.c        |    4 ++--
 drivers/net/ethernet/broadcom/bcm63xx_enet.c  |   12 +++++------
 drivers/net/ethernet/freescale/fec_main.c     |   12 +++++------
 drivers/net/ethernet/xilinx/xilinx_emaclite.c |    6 ++++--
 drivers/pci/host/pci-mvebu.c                  |    5 +++--
 drivers/regulator/ti-abb-regulator.c          |   12 +++++------
 drivers/staging/netlogic/xlr_net.c            |    8 +++----
 drivers/usb/phy/phy-rcar-usb.c                |    2 +-
 include/linux/device.h                        |    2 --
 lib/devres.c                                  |   28 -------------------------
 sound/soc/spear/spdif_out.c                   |   20 +++++-------------
 17 files changed, 55 insertions(+), 91 deletions(-)

CC: alsa-devel@alsa-project.org
CC: devel@driverdev.osuosl.org
CC: linux-can@vger.kernel.org
CC: linux-doc@vger.kernel.org
CC: linux-gpio@vger.kernel.org
CC: linux-mmc@vger.kernel.org
CC: linux-pci@vger.kernel.org
CC: linux-usb@vger.kernel.org
CC: netdev@vger.kernel.org
CC: sparclinux@vger.kernel.org
CC: Bjorn Helgaas <bhelgaas@google.com>
CC: Chris Ball <cjb@laptop.org>
CC: Dan Williams <djbw@fb.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: Felipe Balbi <balbi@ti.com>
CC: Grant Likely <grant.likely@linaro.org>
CC: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
CC: Liam Girdwood <lgirdwood@gmail.com>
CC: Linus Walleij <linus.walleij@linaro.org>
CC: Marc Kleine-Budde <mkl@pengutronix.de>
CC: Mark Brown <broonie@kernel.org>
CC: Michal Simek <michal.simek@xilinx.com>
CC: Rob Landley <rob@landley.net>
CC: Vinod Koul <vinod.koul@intel.com>
CC: Wolfgang Grandegger <wg@grandegger.com>
-- 
1.7.9.5

