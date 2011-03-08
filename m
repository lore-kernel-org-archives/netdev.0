From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 00/14][pull request] Intel Wired LAN Driver Updates
Date: Mon,  7 Mar 2011 18:24:54 -0800
Message-ID: <1299551108-23663-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:37667 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755268Ab1CHC0F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 21:26:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains fixes and cleanups for e1000e and ixgbe, as
well as support for FCoE DDP in target mode for ixgbe.  In igb, added
additional stats for OS2BMC feature.

The following are changes since commit 541ac7c9b30ee2ff84ad87f27e0bc069e143afb5:
  bonding: COW before overwriting the destination MAC address

and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6 master

Carolyn Wyborny (1):
  igb: Add stats output for OS2BMC feature on i350 devices

Don Skidmore (1):
  ixgbe: fix missing function pointer conversion

Emil Tantilov (9):
  e1000e: fix build issue due to undefined reference to crc32_le
  ixgbe: cleanup PHY init
  ixgbe: clear correct counters for flow control on 82599
  ixgbe: Add x540 statistic counter definitions
  ixgbe: Enable flow control pause parameter auto-negotiation support
  ixgbe: add function description
  ixgbe: improve logic in ixgbe_init_mbx_params_pf
  ixgbe: fix spelling errors
  ixgbe: fix setting and reporting of advertised speeds

Yi Zou (3):
  net: add ndo_fcoe_ddp_target() to support FCoE DDP in target mode
  vlan: add support to ndo_fcoe_ddp_target()
  ixgbe: add support to FCoE DDP in target mode

 drivers/net/Kconfig               |    1 +
 drivers/net/igb/e1000_defines.h   |    1 +
 drivers/net/igb/e1000_hw.h        |    4 +
 drivers/net/igb/e1000_regs.h      |    7 +
 drivers/net/igb/igb_ethtool.c     |    9 +-
 drivers/net/igb/igb_main.c        |    9 +
 drivers/net/ixgbe/ixgbe.h         |    2 +
 drivers/net/ixgbe/ixgbe_82598.c   |   38 ++-
 drivers/net/ixgbe/ixgbe_82599.c   |  124 ++++++----
 drivers/net/ixgbe/ixgbe_common.c  |  509 ++++++++++++++++++++++---------------
 drivers/net/ixgbe/ixgbe_ethtool.c |   41 ++--
 drivers/net/ixgbe/ixgbe_fcoe.c    |   86 ++++++-
 drivers/net/ixgbe/ixgbe_fcoe.h    |    4 +
 drivers/net/ixgbe/ixgbe_main.c    |    4 +-
 drivers/net/ixgbe/ixgbe_mbx.c     |   27 +-
 drivers/net/ixgbe/ixgbe_phy.c     |   21 ++-
 drivers/net/ixgbe/ixgbe_phy.h     |    4 +
 drivers/net/ixgbe/ixgbe_type.h    |   10 +
 drivers/net/ixgbe/ixgbe_x540.c    |    9 +-
 include/linux/netdevice.h         |    4 +
 net/8021q/vlan_dev.c              |   14 +
 21 files changed, 608 insertions(+), 320 deletions(-)

-- 
1.7.4

