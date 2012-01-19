From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/9][pull request] Intel Wired LAN Driver Updates
Date: Thu, 19 Jan 2012 00:13:25 -0800
Message-ID: <1326960814-16976-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:7452 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752739Ab2ASINv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jan 2012 03:13:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to igb, igbvf, ixgbe and ixgbevf.
These fixes do the following:
 - update copyright
 - fix sparse and/or namespace warnings
 - make ops tables and strings const
 - fix defines to handle complex expressions
 - remove unnecessary irq enable/disable

The following are changes since commit 17f1bbca1baf2f652fa9c102ec239d6abded94c1:
  net: ftgmac100/ftmac100: add missing interrupt.h include
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Alexander Duyck (1):
  ixgbe: Fix register defines to correctly handle complex expressions

Carolyn Wyborny (1):
  igb: Update Copyright on all Intel copyrighted files.

Greg Rose (1):
  ixgbevf: Prevent possible race condition by checking for message

Mitch A Williams (1):
  igbvf: Remove unnecessary irq disable/enable

Stephen Hemminger (5):
  igb: make local functions static
  igbvf: remove unneeded cast
  ixgbevf: make ethtool ops and strings const
  ixgbevf: fix sparse warnings
  ixgbevf: make operations tables const

 drivers/net/ethernet/intel/igb/Makefile           |    2 +-
 drivers/net/ethernet/intel/igb/e1000_82575.c      |    2 +-
 drivers/net/ethernet/intel/igb/e1000_82575.h      |    2 +-
 drivers/net/ethernet/intel/igb/e1000_defines.h    |    2 +-
 drivers/net/ethernet/intel/igb/e1000_hw.h         |    2 +-
 drivers/net/ethernet/intel/igb/e1000_mac.c        |    4 +-
 drivers/net/ethernet/intel/igb/e1000_mac.h        |    2 +-
 drivers/net/ethernet/intel/igb/e1000_mbx.c        |    2 +-
 drivers/net/ethernet/intel/igb/e1000_mbx.h        |    2 +-
 drivers/net/ethernet/intel/igb/e1000_nvm.c        |    2 +-
 drivers/net/ethernet/intel/igb/e1000_nvm.h        |    2 +-
 drivers/net/ethernet/intel/igb/e1000_phy.c        |    2 +-
 drivers/net/ethernet/intel/igb/e1000_phy.h        |    2 +-
 drivers/net/ethernet/intel/igb/e1000_regs.h       |    2 +-
 drivers/net/ethernet/intel/igb/igb.h              |    2 +-
 drivers/net/ethernet/intel/igb/igb_ethtool.c      |    2 +-
 drivers/net/ethernet/intel/igb/igb_main.c         |   10 +++---
 drivers/net/ethernet/intel/igbvf/ethtool.c        |    3 +-
 drivers/net/ethernet/intel/igbvf/netdev.c         |    5 ---
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h     |   32 ++++++++--------
 drivers/net/ethernet/intel/ixgbevf/ethtool.c      |    5 ++-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |    8 ++--
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   41 +++++++++++----------
 drivers/net/ethernet/intel/ixgbevf/mbx.c          |    3 +-
 drivers/net/ethernet/intel/ixgbevf/vf.c           |    7 ++--
 drivers/net/ethernet/intel/ixgbevf/vf.h           |    2 +-
 26 files changed, 75 insertions(+), 75 deletions(-)

-- 
1.7.7.5
