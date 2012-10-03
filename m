From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/5][pull request] Intel Wired LAN Driver Updates
Date: Wed,  3 Oct 2012 15:27:06 -0700
Message-ID: <1349303231-28855-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:15313 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754475Ab2JCW1Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Oct 2012 18:27:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains fixes/updates to ixgbe only.  There are three
PTP fixes, polling loop fix and the addition of a device id (X540-AT1).

The following are changes since commit 864499449f256e32815575a9b860267ebefa6d70:
  tg3: Fix sparse warnings.
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Emil Tantilov (1):
  ixgbe: fix poll loop for FDIRCTRL.INIT_DONE bit

Jacob Keller (3):
  ixgbe: Fix PTP X540 SDP alignment code for PPS signal
  ixgbe: (PTP) Fix PPS interrupt code
  ixgbe: fix PTP ethtool timestamping function

joshua.a.hay@intel.com (1):
  ixgbe: add support for X540-AT1

 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c   |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c  |   1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   5 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  15 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c     | 202 +++++++++++------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h    |   1 +
 6 files changed, 112 insertions(+), 114 deletions(-)

-- 
1.7.11.4
