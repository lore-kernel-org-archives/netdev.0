From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH/RFC v2 net-next 0/4] ravb: Add support for r8a7795 SoC
Date: Fri, 11 Sep 2015 11:01:14 +0900
Message-ID: <1441936878-18290-1-git-send-email-horms+renesas@verge.net.au>
Cc: linux-arm-kernel@lists.infradead.org,
	Magnus Damm <magnus.damm@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Simon Horman <horms+renesas@verge.net.au>
To: netdev@vger.kernel.org, linux-sh@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series enhances the ravb driver to support the r8a7795 SoC.

Changes:

v1 -> v2
* Address extensive review from Sergei Shtylyov and  Geert Uytterhoeven
  - In particular mandate all 25 interrupts in binding
* Broke brinding change into a separate patch
* New 100Mbit/s limit implementation in ravb driver using
  proposed update to phylib
* Split integration and driver changes into separate patch-sets

Base:

This is based on net-next/master

Availability:

* I will separately post a series,
  "[PATCH/RFC v2 0/5] arm64: dts: r8a7795: enable EthernetAVB on Salvator-X",
  to the linux-sh list to integrate the ravb on the r8a7795/salvatore-x board
* To aid review I will push the following to the renesas tree:
  - driver (this series): (me/r8a7795-ravb-driver-v2)
  - integration: me/r8a7795-ravb-integration-v2
  - both with runtime dependencies: me/r8a7795-ravb-driver-and-integration-v2.runtime
  
Kazuya Mizuguchi (3):
  ravb: Provide dev parameter to DMA API
  ravb: Document binding for r8a7795 SoC
  ravb: Add support for r8a7795 SoC

Simon Horman (1):
  phylib: Add phy_set_max_speed helper

 .../devicetree/bindings/net/renesas,ravb.txt       | 65 +++++++++++++--
 drivers/net/ethernet/renesas/ravb.h                |  7 ++
 drivers/net/ethernet/renesas/ravb_main.c           | 95 +++++++++++++++-------
 drivers/net/phy/phy_device.c                       | 52 +++++++-----
 include/linux/phy.h                                |  1 +
 5 files changed, 166 insertions(+), 54 deletions(-)

-- 
2.1.4

