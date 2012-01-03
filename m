From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/7][pull request] Intel Wired LAN Driver Updates
Date: Mon,  2 Jan 2012 17:50:44 -0800
Message-ID: <1325555451-4697-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:18965 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750860Ab2ACBuy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jan 2012 20:50:54 -0500
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

v2: Dropped the 2 patches to 'add thermal data sensor' to ixgbe while Don/PJ
    review and potentially fix-up the patches based on community feedback.

The following are changes since commit 455ffa607f0efa90c9fec99604553b7cdd5274b2:
  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (1):
  ixgbevf: Fix register defines to correctly handle complex expressions

Carolyn Wyborny (1):
  igb: Add flow control advertising to ethtool setting.

Don Skidmore (1):
  ixgbe: add support for new 82599 device.

Emil Tantilov (3):
  ixgbe: fix incorrect PHY register reads
  ixgbe: add write flush in ixgbe_clock_out_i2c_byte()
  ixgbe: add support for new 82599 device id

Stephen Hemminger (1):
  ixgbe: fix typo's

 drivers/net/ethernet/intel/igb/igb_ethtool.c     |    6 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c   |    1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c  |    8 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   15 ++++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |   26 +++++++++-----
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c     |    1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h    |    2 +
 drivers/net/ethernet/intel/ixgbevf/mbx.h         |    4 +-
 drivers/net/ethernet/intel/ixgbevf/regs.h        |   42 +++++++++++-----------
 9 files changed, 64 insertions(+), 41 deletions(-)

-- 
1.7.7.4
