From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH RFC 0/3] Add ethernet support for r7s72100
Date: Sun, 15 Dec 2013 17:24:43 +0900
Message-ID: <1387095886-15163-1-git-send-email-horms+renesas@verge.net.au>
Cc: Magnus Damm <magnus.damm@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Simon Horman <horms+renesas@verge.net.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

this is a first pass at adding ethernet support to sh-pfc for
the r7s72100 SoC.

It has been written with reference to the hardware documentation
but not well tested.

This series is based on the topic/r7s72100-v3.13-rc3-20131214v2
tag in my renesas tree.

The first patch, for the sh_eth driver, applies cleanly to net-next.

Simon Horman (3):
  sh_eth: Add support for r7s72100
  ARM: shmobile: r7s72100: Add clock for r7s72100-gether
  ARM: shmobile: genmai: Enable r7s72100-gether

 arch/arm/mach-shmobile/board-genmai.c   | 20 ++++++++++++++++++
 arch/arm/mach-shmobile/clock-r7s72100.c |  5 ++++-
 drivers/net/ethernet/renesas/sh_eth.c   | 37 ++++++++++++++++++++++++++++++---
 drivers/net/ethernet/renesas/sh_eth.h   |  2 +-
 4 files changed, 59 insertions(+), 5 deletions(-)

-- 
1.8.4

