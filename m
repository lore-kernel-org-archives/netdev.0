From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH net-next 0/2] ARM64: Add Internal PHY support for Meson GXL
Date: Fri,  4 Nov 2016 16:51:21 +0100
Message-ID: <1478274683-1503-1-git-send-email-narmstrong@baylibre.com>
Cc: Neil Armstrong <narmstrong@baylibre.com>, netdev@vger.kernel.org,
        linux-amlogic@lists.infradead.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: f.fainelli@gmail.com, carlo@caione.org, khilman@baylibre.com,
        andrew@lunn.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Amlogic Meson GXL SoCs have an internal RMII PHY that is muxed with the
external RGMII pins.

In order to support switching between the two PHYs links, extended registers
size for mdio-mux-mmioreg must be added.

The DT related patches submitted as RFC in [3] will be sent in a separate
patchset due to multiple patchsets and DTSI migrations.

Changes since v2 RFC patchset at : [3]
 - Change phy Kconfig/Makefile alphabetic order
 - GXL dtsi cleanup

Changes since original RFC patchset at : [2]
 - Remove meson8b experimental phy switching
 - Switch to mdio-mux-mmioreg with extennded size support
 - Add internal phy support for S905x and p231
 - Add external PHY support for p230

[1] http://lkml.kernel.org/r/1477932286-27482-1-git-send-email-narmstrong@baylibre.com
[2] http://lkml.kernel.org/r/1477060838-14164-1-git-send-email-narmstrong@baylibre.com
[3] http://lkml.kernel.org/r/1477932987-27871-1-git-send-email-narmstrong@baylibre.com

Neil Armstrong (2):
  net: mdio-mux-mmioreg: Add support for 16bit and 32bit register sizes
  net: phy: Add Meson GXL Internal PHY driver

 .../devicetree/bindings/net/mdio-mux-mmioreg.txt   |  4 +-
 drivers/net/phy/Kconfig                            |  5 ++
 drivers/net/phy/Makefile                           |  1 +
 drivers/net/phy/mdio-mux-mmioreg.c                 | 60 ++++++++++++----
 drivers/net/phy/meson-gxl.c                        | 81 ++++++++++++++++++++++
 5 files changed, 136 insertions(+), 15 deletions(-)
 create mode 100644 drivers/net/phy/meson-gxl.c

-- 
1.9.1
