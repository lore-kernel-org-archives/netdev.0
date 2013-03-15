From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: [PATCH 0/5] ARM: sunxi: Add support for A10 Ethernet controller
Date: Fri, 15 Mar 2013 21:49:59 +0100
Message-ID: <1363380605-6577-1-git-send-email-maxime.ripard@free-electrons.com>
Cc: kevin@allwinnertech.com, sunny@allwinnertech.com,
	shuge@allwinnertech.com, netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([94.23.35.102]:56853 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754258Ab3COUuH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Mar 2013 16:50:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The Allwinner A10 SoC has an ethernet that is said to be coming from
Davicom embedded in it. This IP has no public documentation, so exact
details are quite sparse, and this code come from refactored allwinner
code.

Since we don't have any clock support yet for the Allwinner SoCs, we
rely on the bootloader to enable the wemac clock.

Thanks,
Maxime

Maxime Ripard (3):
  ARM: sunxi: Add wemac to sun4i dtsi
  ARM: sun4i: Add muxing options for the ethernet controller
  ARM: hackberry: dt: Add Ethernet controller to the Hackberry device
    tree

Stefan Roese (2):
  net: Add davicom wemac ethernet driver found on Allwinner A10 SoC's
  ARM: cubieboard: Enable ethernet (WEMAC) support in dts

 .../devicetree/bindings/net/davicom-wemac.txt      |   20 +
 arch/arm/boot/dts/sun4i-a10-cubieboard.dts         |    6 +
 arch/arm/boot/dts/sun4i-a10-hackberry.dts          |   19 +
 arch/arm/boot/dts/sun4i-a10.dtsi                   |   18 +
 drivers/net/ethernet/Makefile                      |    2 +-
 drivers/net/ethernet/davicom/Kconfig               |   31 +
 drivers/net/ethernet/davicom/Makefile              |    1 +
 drivers/net/ethernet/davicom/wemac.c               | 1033 ++++++++++++++++++++
 drivers/net/ethernet/davicom/wemac.h               |  130 +++
 9 files changed, 1259 insertions(+), 1 deletion(-)
 create mode 100644 Documentation/devicetree/bindings/net/davicom-wemac.txt
 create mode 100644 drivers/net/ethernet/davicom/wemac.c
 create mode 100644 drivers/net/ethernet/davicom/wemac.h

-- 
1.7.10.4
