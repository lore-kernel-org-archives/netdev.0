From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH net-next 0/4] ravb: Add support for r8a7795 SoC
Date: Wed, 30 Sep 2015 15:15:51 +0900
Message-ID: <1443593755-20991-1-git-send-email-horms+renesas@verge.net.au>
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Magnus Damm <magnus.damm@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

please consider this series for net-next.
It enhances the ravb driver to support the r8a7795 SoC.

Changes:

* Dropped RFC prefix
* Details in changelog of individual patches

Base:

* net-next/master

Availability:

To aid review of this in conjunction with other EtherAVB changes
the following branches are available in my renesas tree on kernel.org.

* me/r8a7795-ravb-driver-v4: this series
* me/r8a7795-ravb-pfc-v2: r8a7795 sh-pfc update for EthernetAVB
* me/r8a7795-ravb-integration-v4: enable EthernetAVB on r8a7795
* me/r8a7795-ravb-driver-and-integration-v4.runtime:
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

