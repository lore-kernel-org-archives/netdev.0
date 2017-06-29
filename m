From: Rafal Ozieblo <rafalo@cadence.com>
Subject: [PATCH v4 0/4] PTP support for macb driver
Date: Thu, 29 Jun 2017 07:08:46 +0100
Message-ID: <1498716526-1372-1-git-send-email-rafalo@cadence.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rafal Ozieblo <rafalo@cadence.com>
To: David Miller <davem@davemloft.net>, <nicolas.ferre@atmel.com>,
        Richard Cochran <richardcochran@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <devicetree@vger.kernel.org>,
        <linux-arm-kernel@lists.infradead.org>,
        <harini.katakam@xilinx.com>, <andrei.pistirica@microchip.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series adds support for PTP synchronization protocol
in Cadence GEM driver based on PHC.

v2 changes:
* removed alarm's support
* removed external time stamp support
* removed PTP event interrupt handling
* removed ptp_hw_support flag
* removed all extra sanity checks
* removed unnecessary #ifdef
* fixed coding style and alligment issues
* renamed macb.c to macb_main.c

v3 changes:
* added checking NULL ptr from ptp_clock_register()
* fixed error codes return
* locals list in "upside down Christmas tree" style
* fixed some other issues from review

v4 changes:
* respin to the newest next-next (28 Jun 2017)
 
Rafal Ozieblo (4):
  net: macb: Add support for PTP timestamps in DMA descriptors
  net: macb: Add tsu_clk to device tree
  net: macb: macb.c changed to macb_main.c
  net: macb: Add hardware PTP support

 Documentation/devicetree/bindings/net/macb.txt |    1 +
 drivers/net/ethernet/cadence/Kconfig           |   10 +-
 drivers/net/ethernet/cadence/Makefile          |    5 +
 drivers/net/ethernet/cadence/macb.c            | 3529 -----------------------
 drivers/net/ethernet/cadence/macb.h            |  158 +-
 drivers/net/ethernet/cadence/macb_main.c       | 3666 ++++++++++++++++++++++++
 drivers/net/ethernet/cadence/macb_ptp.c        |  518 ++++
 7 files changed, 4350 insertions(+), 3537 deletions(-)
 delete mode 100644 drivers/net/ethernet/cadence/macb.c
 create mode 100644 drivers/net/ethernet/cadence/macb_main.c
 create mode 100755 drivers/net/ethernet/cadence/macb_ptp.c

-- 
2.4.5
