From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/6][pull request] Intel Wired LAN Driver Update
Date: Fri, 19 Aug 2011 06:11:20 -0700
Message-ID: <1313759486-23575-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:65409 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751378Ab1HSNL2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Aug 2011 09:11:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to e1000e and ixgbe.

The following are changes since commit ae1511bf769cafeae5ab61aaf9947a16a22cbd10:
  net: rps: support PPPOE session messages
and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (3):
  ixgbe: Refactor transmit map and cleanup routines
  ixgbe: replace reference to CONFIG_FCOE with IXGBE_FCOE
  ixgbe: Cleanup FCOE and VLAN handling in xmit_frame_ring

Amir Hanania (1):
  ixgbe - DDP last user buffer - error to warn

Bruce Allan (2):
  e1000e: convert driver to use extended descriptors
  e1000e: bump driver version number

 drivers/net/ethernet/intel/e1000e/e1000.h       |    3 +-
 drivers/net/ethernet/intel/e1000e/ethtool.c     |    9 +-
 drivers/net/ethernet/intel/e1000e/netdev.c      |  199 +++++----
 drivers/net/ethernet/intel/ixgbe/ixgbe.h        |   27 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c   |   10 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |  554 ++++++++++++----------
 7 files changed, 445 insertions(+), 359 deletions(-)

-- 
1.7.6

