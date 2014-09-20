From: Beniamino Galvani <b.galvani@gmail.com>
Subject: net: stmmac glue layer for Amlogic Meson SoCs
Date: Sat, 20 Sep 2014 15:29:15 +0200
Message-ID: <1411219757-9201-1-git-send-email-b.galvani@gmail.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	"David S. Miller" <davem@davemloft.net>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Carlo Caione <carlo@caione.org>,
	Jerry Cao <jerry.cao@amlogic.com>,
	Victor Wan <victor.wan@amlogic.com>,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
	Beniamino Galvani <b.galvani@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

the Ethernet controller available in Amlogic Meson6 and Meson8 SoCs is
a Synopsys DesignWare MAC IP core, already supported by the stmmac
driver.

These patches add a glue layer to the driver for the platform-specific
settings required by the Amlogic variant.

This has been tested on a Amlogic S802 device with the initial Meson
support submitted by Carlo Caione [1].

[1] http://lwn.net/Articles/612000/

Beniamino Galvani (2):
  net: stmmac: add Amlogic Meson glue layer
  net: stmmac: meson: document device tree bindings

 .../devicetree/bindings/net/meson-dwmac.txt        | 25 ++++++++
 drivers/net/ethernet/stmicro/stmmac/Kconfig        | 10 ++++
 drivers/net/ethernet/stmicro/stmmac/Makefile       |  1 +
 drivers/net/ethernet/stmicro/stmmac/dwmac-meson.c  | 67 ++++++++++++++++++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |  3 +
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  3 +
 6 files changed, 109 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/meson-dwmac.txt
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-meson.c

-- 
1.9.1
