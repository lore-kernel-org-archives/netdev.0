From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/9][pull request] Intel Wired LAN Driver Updates
Date: Fri, 23 Dec 2011 01:09:08 -0800
Message-ID: <1324631357-31789-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:44079 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752658Ab1LWJJT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Dec 2011 04:09:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to igb, ixgbe and ixgbevf.  Most of
the changes are adding support of some kind.  There are 3 fixes, one fix
for ixgbevf to fix register defines.  The other two fixes are for ixgbe,
one being a minor comment spelling fix and the other is to fix register
reads.

Here is a list of the new support added:
 - 2 new device id's in ixgbe
 - igb flow control advertising to ethtool
 - ixgbe thermal data sensor

The following are changes since commit 2c64580046a122fa15bb586d8ca4fd5e4b69a1e7:
  netlink: wake up netlink listeners sooner (v2)
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (1):
  ixgbevf: Fix register defines to correctly handle complex expressions

Carolyn Wyborny (1):
  igb: Add flow control advertising to ethtool setting.

Don Skidmore (3):
  ixgbe: add support functions for gathering thermal data sensor
  ixgbe: add interface to export thermal data
  ixgbe: add support for new 82599 device.

Emil Tantilov (3):
  ixgbe: fix incorrect PHY register reads
  ixgbe: add write flush in ixgbe_clock_out_i2c_byte()
  ixgbe: add support for new 82599 device id

Stephen Hemminger (1):
  ixgbe: fix typo's

 drivers/net/ethernet/intel/igb/igb_ethtool.c     |    6 +-
 drivers/net/ethernet/intel/ixgbe/Makefile        |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |    4 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c   |    3 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c  |  158 +++++++++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h  |   13 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   15 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |   32 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c     |    1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c   |  305 ++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h    |   40 +++
 drivers/net/ethernet/intel/ixgbevf/mbx.h         |    4 +-
 drivers/net/ethernet/intel/ixgbevf/regs.h        |   42 ++--
 13 files changed, 583 insertions(+), 42 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c

-- 
1.7.7.4
