From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/14][pull request] Intel Wired LAN Driver Updates
Date: Wed, 23 Jan 2013 14:44:36 -0800
Message-ID: <1358981090-5794-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:52933 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752378Ab3AWWpQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2013 17:45:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe and ixgbevf.  Majority of the
changes are against ixgbe PTP and SR-IOV.

The following are changes since commit 93b9c1ddd3fb4a5b67d512e534b30070f9ecec28:
  Merge branch 'testing' of git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (1):
  ixgbe: Inline Rx PTP descriptor handling

Donald Dutile (1):
  ixgbe: Limit number of reported VFs to device specific value

Greg Rose (4):
  ixgbe: Make mailbox ops initialization unconditional
  ixgbe: Modularize SR-IOV enablement code
  ixgbe: Implement PCI SR-IOV sysfs callback operation
  ixgbevf: Fix link speed message to support 100Mbps

Jacob Keller (8):
  ixgbe: ethtool ixgbe_diag_test cleanup
  ixgbe: add missing supported filters to get_ts_info
  ixgbe: Update ptp_overflow check comment and jiffies
  ixgbe: Use watchdog check in favor of BPF for detecting latched
    timestamp
  ixgbe: Add ptp work item to poll for the Tx timestamp
  ixgbe: add warning when scheduling reset
  ixgbe: Fix overwriting of rx_mtrl in ixgbe_ptp_hwtstamp_ioctl
  ixgbe: only compile ixgbe_debugfs.o when enabled

 drivers/net/ethernet/intel/ixgbe/Makefile         |   3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h          |  34 +++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c  |   5 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c  |  46 +++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |  62 +++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c      | 221 ++++++++++------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    | 192 ++++++++++++++-----
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h    |   6 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  19 +-
 9 files changed, 375 insertions(+), 213 deletions(-)

-- 
1.7.11.7
