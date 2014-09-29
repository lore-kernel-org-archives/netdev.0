From: Markus Pargmann <mpa@pengutronix.de>
Subject: [PATCH RESEND v6 0/7] net: cpsw: Support for am335x chip MACIDs
Date: Mon, 29 Sep 2014 08:53:12 +0200
Message-ID: <1411973599-18908-1-git-send-email-mpa@pengutronix.de>
Cc: =?UTF-8?q?Beno=C3=AEt=20Cousson?= <bcousson@baylibre.com>,
	Tony Lindgren <tony@atomide.com>,
	Wolfram Sang <wsa@the-dreams.de>,
	Steven Rostedt <rostedt@goodmis.org>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	linux-omap@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	kernel@pengutronix.de, Markus Pargmann <mpa@pengutronix.de>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-omap-owner@vger.kernel.org>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Another resend of this series to add the netdev list.

This series adds support to the cpsw driver to read the MACIDs of the am335x
chip and use them as fallback. These addresses are only used if there are no
mac addresses in the devicetree, for example set by a bootloader.

Best regards,

Markus


Markus Pargmann (7):
  DT doc: net: cpsw mac-address is optional
  net: cpsw: Add missing return value
  net: cpsw: header, Add missing include
  net: cpsw: Replace pr_err by dev_err
  net: cpsw: Add am33xx MACID readout
  am33xx: define syscon control module device node
  arm: dts: am33xx, Add syscon phandle to cpsw node

 Documentation/devicetree/bindings/net/cpsw.txt |  6 +++-
 arch/arm/boot/dts/am33xx.dtsi                  |  6 ++++
 drivers/net/ethernet/ti/Kconfig                |  2 ++
 drivers/net/ethernet/ti/cpsw.c                 | 45 ++++++++++++++++++++++++--
 drivers/net/ethernet/ti/cpsw.h                 |  1 +
 5 files changed, 57 insertions(+), 3 deletions(-)

-- 
2.1.0

