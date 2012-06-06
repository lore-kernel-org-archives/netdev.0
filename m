From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/3][pull request] Intel Wired LAN Driver Updates
Date: Tue,  5 Jun 2012 21:08:52 -0700
Message-ID: <1338955735-8967-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:49278 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753218Ab2FFEI6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2012 00:08:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains 2 fixes for ixgbe and a fix for e1000e.

The following are changes since commit dc5cd894cace7bda4a743487a9f87d59a3f0a095:
  net/hyperv: Use wait_event on outstanding sends during device removal
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Bruce Allan (1):
  e1000e: test for valid check_reset_block function pointer

John Fastabend (2):
  ixgbe: fix_features rxvlan is independent of DCB and needs to be set
  ixgbe: IXGBE_RXD_STAT_VP set even with Rx stripping enabled

 drivers/net/ethernet/intel/e1000e/ethtool.c   |    6 ++++--
 drivers/net/ethernet/intel/e1000e/mac.c       |    2 +-
 drivers/net/ethernet/intel/e1000e/netdev.c    |    4 ++--
 drivers/net/ethernet/intel/e1000e/phy.c       |    8 +++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   22 ++++++++++------------
 5 files changed, 22 insertions(+), 20 deletions(-)

-- 
1.7.10.2
