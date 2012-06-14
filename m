From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/6][pull request] Intel Wired LAN Driver Updates
Date: Thu, 14 Jun 2012 03:18:03 -0700
Message-ID: <1339669089-27955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:6172 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755566Ab2FNKSM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jun 2012 06:18:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000 and ixgbe.

The following are changes since commit 0450243096de90ff51c3a6c605410c5e28d79f8d:
  bonding: drop_monitor aware
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Bruce Allan (1):
  e1000e: use more informative logging macros when netdev not yet
    registered

Emil Tantilov (1):
  ixgbe: do not compile ixgbe_sysfs.c when CONFIG_IXGBE_HWMON is not
    set

Jacob Keller (3):
  ixgbe: ptp code cleanup
  ixgbe: PTP Fix hwtstamp mode settings
  ixgbe: Check PTP Rx timestamps via BPF filter

John Fastabend (1):
  ixgbe: align flow control DV macros with datasheet

 drivers/net/ethernet/intel/e1000e/netdev.c     |   11 +-
 drivers/net/ethernet/intel/e1000e/param.c      |   43 ++++---
 drivers/net/ethernet/intel/ixgbe/Makefile      |    4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h       |    2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |   11 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c   |  149 ++++++++++++++++++------
 drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c |    2 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h  |   37 +++---
 8 files changed, 180 insertions(+), 79 deletions(-)

-- 
1.7.10.2
