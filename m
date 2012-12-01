From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/9][pull request] Intel Wired LAN Driver Updates
Date: Sat,  1 Dec 2012 03:53:28 -0800
Message-ID: <1354362817-26168-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:27557 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751646Ab2LALx4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2012 06:53:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe, igb and e1000e.  Majority of the
changes are against igb.

The following are changes since commit 1b4c44e6369dbbafd113f1e00b406f1eda5ab5b2:
  myri10ge: Add vlan rx for better GRO perf.
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Akeem G. Abodunrin (1):
  igb: Acquire, release semaphore for writing each EEPROM page

Alexander Duyck (1):
  ixgbe: Do not parse past IP header on fragments beyond the first

Bruce Allan (1):
  e1000e: cosmetic cleanup of comments

Carolyn Wyborny (5):
  igb: Updates to read nvm function for i211 device
  igb: Refactoring of i210 file.
  igb: Workaround for global device reset problem on 82580.
  igb: Unset sigdetect for SERDES loopback on 82580 and i350
  igb: Fix SerDes autoneg flow control.

Joshua Hay (1):
  ixgbe: eliminate Smatch warnings in ixgbe_debugfs.c

 drivers/net/ethernet/intel/e1000e/80003es2lan.c  |  66 ++---
 drivers/net/ethernet/intel/e1000e/82571.c        | 115 +++------
 drivers/net/ethernet/intel/e1000e/defines.h      |  27 +-
 drivers/net/ethernet/intel/e1000e/e1000.h        |  17 +-
 drivers/net/ethernet/intel/e1000e/ethtool.c      |  69 ++---
 drivers/net/ethernet/intel/e1000e/hw.h           |   6 +-
 drivers/net/ethernet/intel/e1000e/ich8lan.c      | 243 ++++++------------
 drivers/net/ethernet/intel/e1000e/mac.c          | 135 ++++------
 drivers/net/ethernet/intel/e1000e/manage.c       |   9 +-
 drivers/net/ethernet/intel/e1000e/netdev.c       | 313 +++++++++--------------
 drivers/net/ethernet/intel/e1000e/nvm.c          |  15 +-
 drivers/net/ethernet/intel/e1000e/param.c        |  50 ++--
 drivers/net/ethernet/intel/e1000e/phy.c          | 141 ++++------
 drivers/net/ethernet/intel/igb/e1000_82575.c     |  49 +++-
 drivers/net/ethernet/intel/igb/e1000_defines.h   |   7 +
 drivers/net/ethernet/intel/igb/e1000_i210.c      | 275 +++++++++++---------
 drivers/net/ethernet/intel/igb/e1000_i210.h      |   6 +
 drivers/net/ethernet/intel/igb/e1000_mac.c       | 124 +++++++++
 drivers/net/ethernet/intel/igb/e1000_nvm.c       |  28 +-
 drivers/net/ethernet/intel/igb/igb.h             |   2 +
 drivers/net/ethernet/intel/igb/igb_ethtool.c     |  14 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c |  83 +++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  13 +-
 23 files changed, 823 insertions(+), 984 deletions(-)

-- 
1.7.11.7
