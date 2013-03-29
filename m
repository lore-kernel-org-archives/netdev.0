From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 0/4] mv643xx_eth device tree bindings
Date: Fri, 29 Mar 2013 19:14:35 +0100
Message-ID: <1364580879-4297-1-git-send-email-florian@openwrt.org>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	devicetree-discuss@lists.ozlabs.org,
	thomas.petazzoni@free-electrons.com, jm@lentin.co.uk,
	moinejf@free.fr, sebastian.hesselbarth@gmail.com,
	buytenh@wantstofly.org, andrew@lunn.ch, jason@lakedaemon.net,
	grant.likely@secretlab.ca, rob.herring@calxeda.com,
	Florian Fainelli <florian@openwrt.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:34567 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756296Ab3C2SOy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Mar 2013 14:14:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch serie implements mv643xx_eth device tree bindings. I opted for
the reuse of the bindings already defined in
Documentation/devicetree/bindings/marvell.txt so that we do not create
any confusion.

For reference, I have included the mv643xx-eth related nodes in the
corresponding Kirkwood, Dove and Orion5x .dtsi files so you can more
easily test on your own platforms.

I tested these on a custom 88F6181-based boards, but I would appreciate
more testing.

Thanks!

Florian Fainelli (4):
  mv643xx_eth: add Device Tree bindings
  ARM: kirkwood: add device node entries for the gigabit interfaces
  ARM: orion5x: add gigabit ethernet device tree node
  ARM: dove: add gigabit device tree nodes to dove.dtsi

 Documentation/devicetree/bindings/marvell.txt |   21 ++++-
 arch/arm/boot/dts/dove.dtsi                   |   25 ++++++
 arch/arm/boot/dts/kirkwood.dtsi               |   46 ++++++++++
 arch/arm/boot/dts/orion5x.dtsi                |   23 +++++
 arch/arm/mach-kirkwood/common.c               |    4 +-
 drivers/net/ethernet/marvell/mv643xx_eth.c    |  114 ++++++++++++++++++++++++-
 6 files changed, 226 insertions(+), 7 deletions(-)

-- 
1.7.10.4
