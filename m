From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH/RFC net-next v3 0/4] ravb: Add support for r8a7795 SoC
Date: Fri, 18 Sep 2015 15:03:19 +0900
Message-ID: <1442556203-657-1-git-send-email-horms+renesas@verge.net.au>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Magnus Damm <magnus.damm@gmail.com>
To: netdev@vger.kernel.org, linux-sh@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series enhances the ravb driver to support the r8a7795 SoC.

Changes:

* Details in changelog of individual patches

Base:

* net-next/master

Availability:

To aid review of this and other EtherAVB the following branches are
available in my renesas tree on kernel.org.

* me/r8a7795-ravb-driver-v3: this series
* me/r8a7795-ravb-pfc-v2: r8a7795 sh-pfc update for EthernetAVB
* me/r8a7795-ravb-integration-v3: enable EthernetAVB on r8a7795
* me/r8a7795-ravb-driver-and-integration-v3.runtime:
      the above three branches with their runtime dependencies


Kazuya Mizuguchi (3):
  ravb: Provide dev parameter to DMA API
  ravb: Document binding for r8a7795 SoC
  ravb: Add support for r8a7795 SoC

Simon Horman (1):
  phylib: Add phy_set_max_speed helper

 .../devicetree/bindings/net/renesas,ravb.txt       |  69 ++++++++++++--
 drivers/net/ethernet/renesas/ravb.h                |   7 ++
 drivers/net/ethernet/renesas/ravb_main.c           | 101 +++++++++++++++------
 drivers/net/phy/phy_device.c                       |  59 ++++++++----
 include/linux/phy.h                                |   1 +
 5 files changed, 184 insertions(+), 53 deletions(-)

-- 
2.1.4

