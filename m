From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 00/21][pull request] Intel Wired LAN Driver Updates
Date: Sat, 12 Mar 2011 04:20:07 -0800
Message-ID: <1299932428-3114-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:39426 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751145Ab1CLMUf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Mar 2011 07:20:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains a version string fix and bump for ixgbevf,
added functionality for i350 devices in igb, and cleanups and fixes in
ixgbe (mainly DCB changes).

The following are changes since commit 70d279a7e2a6e308530822ba2bf4134cc0f5c091:
  e1000e: bump version number
and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6 master

Carolyn Wyborny (4):
  igb: Add Energy Efficient Ethernet (EEE) for i350 devices.
  igb: Update NVM functions to work with i350 devices
  igb: Add DMA Coalescing feature to driver
  igb: Bump version to 3.0.6

Emil Tantilov (3):
  ixgbe: remove timer reset to 0 on timeout
  ixgbe: update PHY code to support 100Mbps as well as 1G/10G
  ixgbe: correct typo in define name

Greg Rose (2):
  ixgbevf: Fix Version String
  ixgbevf: Fix Driver String

John Fastabend (11):
  ixgbe: DCB, implement capabilities flags
  ixgbe: DCB, implement ieee_setapp dcbnl ops
  ixgbe: DCB remove ixgbe_fcoe_getapp routine
  ixgbe: DCB, use multiple Tx rings per traffic class
  ixgbe: enable ndo_tc_setup
  ixgbe: DCB: enable RSS to be used with DCB
  ixgbe: DCB, missed translation from 8021Qaz TSA to CEE link strict
  ixgbe: IEEE 802.1Qaz, implement priority assignment table
  ixgbe: DCB during ifup use correct CEE or IEEE mode
  ixgbe: DCB, set minimum bandwidth per traffic class
  ixgbe: DCB, PFC not cleared until reset occurs

Lior Levy (1):
  ixgbe: add support for VF Transmit rate limit using iproute2

 drivers/net/igb/e1000_82575.c       |  285 +++++++++++++++++++++++-
 drivers/net/igb/e1000_82575.h       |    1 +
 drivers/net/igb/e1000_defines.h     |   39 +++-
 drivers/net/igb/e1000_hw.h          |    4 +-
 drivers/net/igb/e1000_nvm.c         |   64 +++++-
 drivers/net/igb/e1000_nvm.h         |    1 +
 drivers/net/igb/e1000_regs.h        |   13 +
 drivers/net/igb/igb.h               |    6 +
 drivers/net/igb/igb_ethtool.c       |    8 +-
 drivers/net/igb/igb_main.c          |   76 ++++++-
 drivers/net/ixgbe/ixgbe.h           |    7 +-
 drivers/net/ixgbe/ixgbe_82598.c     |    1 +
 drivers/net/ixgbe/ixgbe_dcb.c       |   37 +---
 drivers/net/ixgbe/ixgbe_dcb.h       |    4 +-
 drivers/net/ixgbe/ixgbe_dcb_82598.c |   44 ++--
 drivers/net/ixgbe/ixgbe_dcb_82599.c |   71 +++---
 drivers/net/ixgbe/ixgbe_dcb_82599.h |    9 +-
 drivers/net/ixgbe/ixgbe_dcb_nl.c    |  226 ++++++++++++++-----
 drivers/net/ixgbe/ixgbe_fcoe.c      |   15 --
 drivers/net/ixgbe/ixgbe_main.c      |  425 ++++++++++++++++++++---------------
 drivers/net/ixgbe/ixgbe_mbx.c       |    6 -
 drivers/net/ixgbe/ixgbe_phy.c       |  335 +++++++++++++++++++--------
 drivers/net/ixgbe/ixgbe_phy.h       |    1 +
 drivers/net/ixgbe/ixgbe_sriov.c     |   85 +++++++-
 drivers/net/ixgbe/ixgbe_sriov.h     |    1 +
 drivers/net/ixgbe/ixgbe_type.h      |   13 +
 drivers/net/ixgbevf/ethtool.c       |    4 +-
 drivers/net/ixgbevf/ixgbevf_main.c  |    4 +-
 drivers/net/ixgbevf/regs.h          |    2 +-
 29 files changed, 1317 insertions(+), 470 deletions(-)

-- 
1.7.4

