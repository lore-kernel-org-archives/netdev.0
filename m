From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/9][pull request] Intel Wired LAN Driver Updates
Date: Sat,  9 Jun 2012 01:20:54 -0700
Message-ID: <1339230063-12545-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:16442 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751505Ab2FIIVG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jun 2012 04:21:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to igb and ixgbe.

The following are changes since commit fbfe95a42e90b3dd079cc9019ba7d7700feee0f6:
  inet: Create and use rt{,6}_get_peer_create().
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Carolyn Wyborny (4):
  igb: Add support functions to access thermal data.
  igb: Add hwmon interface to export thermal data.
  igb: Update firmware info output
  igb: Version bump

Emil Tantilov (1):
  ixgbe: do not compile ixgbe_sysfs.c when CONFIG_IXGBE_HWMON is not
    set

Jacob Keller (3):
  ixgbe: ptp code cleanup
  ixgbe: PTP Fix hwtstamp mode settings
  ixgbe: Check PTP Rx timestamps via BPF filter

John Fastabend (1):
  ixgbe: align flow control DV macros with datasheet

 drivers/net/ethernet/intel/Kconfig             |   10 +
 drivers/net/ethernet/intel/igb/Makefile        |    2 +-
 drivers/net/ethernet/intel/igb/e1000_82575.c   |  659 +++++++++++++++++++++++-
 drivers/net/ethernet/intel/igb/e1000_82575.h   |   31 ++
 drivers/net/ethernet/intel/igb/e1000_defines.h |   15 +-
 drivers/net/ethernet/intel/igb/e1000_hw.h      |   21 +-
 drivers/net/ethernet/intel/igb/e1000_regs.h    |   15 +
 drivers/net/ethernet/intel/igb/igb.h           |   44 ++
 drivers/net/ethernet/intel/igb/igb_ethtool.c   |   16 +-
 drivers/net/ethernet/intel/igb/igb_main.c      |   97 +++-
 drivers/net/ethernet/intel/igb/igb_sysfs.c     |  245 +++++++++
 drivers/net/ethernet/intel/ixgbe/Makefile      |    4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h       |    2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |   11 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c   |  149 ++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c |    2 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h  |   37 +-
 17 files changed, 1284 insertions(+), 76 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/igb/igb_sysfs.c

-- 
1.7.10.2
