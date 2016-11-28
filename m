From: Harini Katakam <harini.katakam@xilinx.com>
Subject: [RFC PATCH 0/2] Multi phy management
Date: Mon, 28 Nov 2016 15:19:01 +0530
Message-ID: <1480326541-5947-1-git-send-email-harinik@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <devicetree@vger.kernel.org>, <harinik@xilinx.com>,
        <michals@xilinx.com>
To: <nicolas.ferre@atmel.com>, <davem@davemloft.net>,
        <robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
        <ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
        <boris.brezillon@free-electrons.com>,
        <alexandre.belloni@free-electrons.com>,
        <harinikatakamlinux@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series is to add support for the hardware with multiple ethernet
MAC controllers and a single MDIO bus connected to multiple PHY devices.
MDIO lines are connected to any one of the ethernet MAC controllers and
all the PHY devices will be accessed using the PHY maintenance interface
in that MAC controller.
This handling along with PHY functionality is moved to macb_mdio.c
within the macb driver space.
This is because of the phy maintenance register is within the MAC.
Please advise on how to proceed with handling such a requirement.

Harini Katakam (2):
  net: macb: Add MDIO driver for accessing multiple PHY devices
  Documentation: devictree: Add macb mdio bindings

 .../devicetree/bindings/net/macb-mdio.txt          |  31 +++
 drivers/net/ethernet/cadence/Makefile              |   2 +-
 drivers/net/ethernet/cadence/macb.c                | 169 ++-----------
 drivers/net/ethernet/cadence/macb.h                |   2 +
 drivers/net/ethernet/cadence/macb_mdio.c           | 266 +++++++++++++++++++++
 5 files changed, 325 insertions(+), 145 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/macb-mdio.txt
 create mode 100644 drivers/net/ethernet/cadence/macb_mdio.c

-- 
2.7.4
