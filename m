From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/5][pull request] Intel Wired LAN Driver Updates
Date: Wed, 11 Jul 2012 02:09:24 -0700
Message-ID: <1341997769-22034-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:65340 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751897Ab2GKJJc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2012 05:09:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe.

The following are changes since commit 4715213d9cf40285492fff4092bb1fa8e982f632:
  bridge: fix endian
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (5):
  ixgbe: count q_vectors instead of MSI-X vectors
  ixgbe: Add upper limit to ring features
  ixgbe: Add feature offset value to ring features
  ixgbe: Clean up a useless switch statement and dead code in
    configure_srrctl
  ixgbe: Merge RSS and flow director ring register caching and
    configuration

 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |   20 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |    8 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c    |    8 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c     |  150 ++++++++--------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  150 +++++++++-------------
 5 files changed, 127 insertions(+), 209 deletions(-)

-- 
1.7.10.4
