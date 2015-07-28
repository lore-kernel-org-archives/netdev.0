From: Lars Persson <lars.persson@axis.com>
Subject: [PATCH net-next 0/4] dwc_eth_qos: Add support for Synopsys DWC Ethernet QoS
Date: Tue, 28 Jul 2015 12:01:46 +0200
Message-ID: <1438077710-19175-1-git-send-email-larper@axis.com>
Cc: andire@axis.com, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, Lars Persson <larper@axis.com>
To: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a driver supporting version 4.10a of the Synopsys DWC Ethernet QoS
gigabit ethernet controller. The IP has changed significantly compared to the
dwmac1000 so a separate driver is justified.

The IP is highly configurable at synthesis time. This driver has been
developed for a subset of the total available feature set. Currently
it supports:
* TSO
* Checksum offload for RX and TX.
* Energy efficient ethernet.
* GMII phy interface.
* The statistics module.
* Single RX and TX queue.

Lars Persson (4):
  dwc_eth_qos: Add Synopsys DWC Ethernet QoS bindings
  dwc_eth_qos: Add support for Synopsys DWC Ethernet QoS
  dwc_eth_qos: Add the synopsys folder to the build system.
  dwc_eth_qos: Add maintainer info

 .../bindings/net/snps,dwc-qos-ethernet.txt         |   75 +
 MAINTAINERS                                        |    7 +
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/synopsys/Kconfig              |   27 +
 drivers/net/ethernet/synopsys/Makefile             |    5 +
 drivers/net/ethernet/synopsys/dwc_eth_qos.c        | 3019 ++++++++++++++++++++
 7 files changed, 3135 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/snps,dwc-qos-ethernet.txt
 create mode 100644 drivers/net/ethernet/synopsys/Kconfig
 create mode 100644 drivers/net/ethernet/synopsys/Makefile
 create mode 100644 drivers/net/ethernet/synopsys/dwc_eth_qos.c

-- 
2.1.4
