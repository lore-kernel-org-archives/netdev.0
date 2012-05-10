From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/12][pull request] Intel Wired LAN Driver Updates
Date: Wed,  9 May 2012 23:46:41 -0700
Message-ID: <1336632413-19135-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:22833 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752333Ab2EJGq5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2012 02:46:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches contains updates for igb and ixgbe.
Special note ixgbe patches contain the addition of PTP support from
Jacob Keller.

The following are changes since commit 8feedbb4a710784d2858acba5c90e903e93e36eb:
  dsa: Convert compare_ether_addr to ether_addr_equal
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (3):
  ixgbe: Exit on error case in VF message processing
  ixgbe: Clean up priority based flow control
  ixgbe: Set Drop_EN bit when multiple Rx queues are present w/o flow
    control

Don Skidmore (2):
  ixgbe: cleanup the hwmon function calls
  ixgbe: update version number

Greg Rose (1):
  ixgbe: Fix bogus error message

Jacob E Keller (1):
  ixgbe: Enable timesync clock-out feature for PPS support on X540

Jacob Keller (4):
  ixgbe: Hardware Timestamping + PTP Hardware Clock (PHC)
  ixgbe: correct disable_rx_buff timeout
  ixgbe: add support for get_ts_info
  ixgbe: support software timestamping

Koki Sanagi (1):
  igb: output register's information related to RX/TX queue[4-15]

 drivers/net/ethernet/intel/Kconfig                 |   11 +
 drivers/net/ethernet/intel/igb/igb_ethtool.c       |   38 +-
 drivers/net/ethernet/intel/ixgbe/Makefile          |    2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe.h           |   37 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c    |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82598.c |   69 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c |   93 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c    |   98 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c   |   71 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |  198 ++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c       |  900 ++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c     |   13 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c     |   36 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h      |   47 +-
 14 files changed, 1370 insertions(+), 245 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c

-- 
1.7.7.6
