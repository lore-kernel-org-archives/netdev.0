From: Shawn Guo <shawn.guo@linaro.org>
Subject: [PATCH 0/3] Add basic device support for imx51 babbage
Date: Sat, 18 Jun 2011 23:19:11 +0800
Message-ID: <1308410354-21387-1-git-send-email-shawn.guo@linaro.org>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org, patches@linaro.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch set adds the basic device tree support for imx51 babbage
board.  With uart and fec dt support added, the dt kernel can boot
into console with nfs root on babbage, so that we get a good base
to start playing dt and converting further drivers to use dt on
imx51.

It creates the platform imx51-dt for using the device tree, and
leaves existing board support files alone, so nothing should be
broken.  The plan is to add stuff step by step into imx51-dt to
get it support every existing imx51 boards, and then remove the
existing board files.

It works against Linus tree plus the dt infrastructure patches
posted by Grant Likely as part of the following series.

  [RFC PATCH 00/11] Full device tree support for ARM Versatile

Comments are appreciated.

Shawn Guo (3):
      serial/imx: add device tree support
      net/fec: add device tree support
      ARM: mx5: add basic device tree support for imx51 babbage

 Documentation/devicetree/bindings/net/fsl-fec.txt  |   14 +++
 .../bindings/tty/serial/fsl-imx-uart.txt           |   21 +++++
 arch/arm/boot/dts/imx51-babbage.dts                |   89 ++++++++++++++++++++
 arch/arm/mach-mx5/Kconfig                          |    8 ++
 arch/arm/mach-mx5/Makefile                         |    1 +
 arch/arm/mach-mx5/imx51-dt.c                       |   70 +++++++++++++++
 drivers/net/fec.c                                  |   28 ++++++
 drivers/tty/serial/imx.c                           |   81 ++++++++++++++++--
 8 files changed, 302 insertions(+), 10 deletions(-)
