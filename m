From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH v5 0/4] Add ethernet support for r7s72100
Date: Wed, 15 Jan 2014 15:12:17 +0900
Message-ID: <1389766341-14001-1-git-send-email-horms+renesas@verge.net.au>
Cc: linux-arm-kernel@lists.infradead.org,
	Magnus Damm <magnus.damm@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Simon Horman <horms+renesas@verge.net.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

this series adds ethernet support to sh-pfc for the r7s72100 SoC.

This series is based on a merge of:
* The topic/r7s72100-v3.13-rc8-20140115 tag in my renesas tree
* net-next
  - Head revision: 08c93cd99b2f31ba9
    ("Merge branch 'for-davem' of git://gitorious.org/linux-can/linux-can-next")

The first two patches, targeted at net-next, also applies cleanly there.

Changes since v4
* Addressed feedback from Sergei Shtylyov as detailed in the changelog
  of "sh_eth: Add support for r7s72100"
* Rebase

Changes since v3
* Use bool as return type of sh_eth_is_gether()
  and sh_eth_is_rz_fast_ether()
* Correct coding style in sh_eth_get_stats()

Changes since v2
* Trivial rebase
* Dropped "RFC" from subject

Changes since v1 are noted in the changelog of each patch.

Simon Horman (4):
  sh_eth: Use bool as return type of sh_eth_is_gether()
  sh_eth: Add support for r7s72100
  ARM: shmobile: r7s72100: Add clock for r7s72100-ether
  ARM: shmobile: genmai: Enable r7s72100-ether

 arch/arm/mach-shmobile/board-genmai.c   |  21 +++++
 arch/arm/mach-shmobile/clock-r7s72100.c |   4 +
 drivers/net/ethernet/renesas/sh_eth.c   | 132 +++++++++++++++++++++++++++++---
 drivers/net/ethernet/renesas/sh_eth.h   |   3 +-
 4 files changed, 149 insertions(+), 11 deletions(-)

-- 
1.8.4

