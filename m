From: Roger Quadros <rogerq@ti.com>
Subject: [PATCH 0/2] ARM: am335x-icev2: Add ethernet support
Date: Mon, 13 Mar 2017 15:42:32 +0200
Message-ID: <1489412554-2054-1-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <grygorii.strashko@ti.com>, <nsekhar@ti.com>, <jsarha@ti.com>,
        <linux-omap@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, Roger Quadros <rogerq@ti.com>
To: <davem@davemloft.net>, <tony@atomide.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This series adds ethernet support to am335x-icev2 board.

The ethernet PHYs on the board need an explicit GPIO reset pulse
to ensure they bootstrap to the correct mode. Without the
GPIO reset they just don't work.

cheers,
-roger

Roger Quadros (2):
  net: davinci_mdio: add GPIO reset logic
  ARM: dts: am335x-icev2: Add CPSW ethernet0 and ethernet1

 .../devicetree/bindings/net/davinci-mdio.txt       |   2 +
 arch/arm/boot/dts/am335x-icev2.dts                 | 113 +++++++++++++++++++++
 drivers/net/ethernet/ti/davinci_mdio.c             |  68 +++++++++++--
 3 files changed, 175 insertions(+), 8 deletions(-)

-- 
2.7.4
