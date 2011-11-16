From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/8][pull request] Intel Wired LAN Driver Updates
Date: Wed, 16 Nov 2011 04:51:24 -0800
Message-ID: <1321447892-14381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:24667 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755260Ab1KPMvf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Nov 2011 07:51:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to e1000, e1000e, igb, igbvf,
ixgbe and ixgbevf.  There is one fix for LED blink logic for ixgbe,
the remaining patches are conversions of printk's to pr_<level>.

The following are changes since commit 229a66e3bec97563aa92e25dfe0bc60b0d468619:
  IPv6: Removing unnecessary NULL checks.
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-organize master

Emil Tantilov (1):
  ixgbe: fix LED blink logic to check for link

Jeff Kirsher (4):
  e1000e: Convert printks to pr_<level>
  igbvf: Convert printks to pr_<level>
  ixgbevf: Convert printks to pr_<level>
  igb: Convert printks to pr_<level>

Jesse Brandeburg (1):
  e1000e: convert to real ndo_set_rx_mode

Joe Perches (2):
  igb: Convert bare printk to pr_notice
  intel: Convert <FOO>_LENGTH_OF_ADDRESS to ETH_ALEN

 drivers/net/ethernet/intel/e1000/e1000_hw.h       |    1 -
 drivers/net/ethernet/intel/e1000e/netdev.c        |  388 ++++++++++++---------
 drivers/net/ethernet/intel/igb/e1000_82575.c      |    5 +-
 drivers/net/ethernet/intel/igb/igb_main.c         |  165 +++++-----
 drivers/net/ethernet/intel/igbvf/netdev.c         |   14 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h     |    8 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c     |   18 +-
 drivers/net/ethernet/intel/ixgbevf/defines.h      |    1 -
 drivers/net/ethernet/intel/ixgbevf/ethtool.c      |    6 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   27 +-
 drivers/net/ethernet/intel/ixgbevf/vf.c           |    4 +-
 12 files changed, 340 insertions(+), 299 deletions(-)

-- 
1.7.6.4
