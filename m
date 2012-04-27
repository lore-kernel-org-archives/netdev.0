From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/6][pull request] Intel Wired LAN Driver Updates
Date: Fri, 27 Apr 2012 02:36:47 -0700
Message-ID: <1335519413-1892-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:58063 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759151Ab2D0Jgz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2012 05:36:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches contains updates for e1000e, igb and
ixgbe.

The following are changes since commit 82981930125abfd39d7c8378a9cfdf5e1be2002b:
  net: cleanups in sock_setsockopt()
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Bruce Allan (2):
  e1000e: 82579 packet drop workaround
  e1000e: 82579 potential system hang on stress when ME enabled

Jacob Keller (1):
  ixgbe: check for WoL support in single function

Matthew Vick (3):
  e1000e: Disable Far-End LoopBack following reset on 80003ES2LAN.
  e1000e: Enable DMA Burst Mode on 82574 by default.
  igb: Force flow control off during reset when forcing speed.

 drivers/net/ethernet/intel/e1000e/80003es2lan.c  |    8 ++
 drivers/net/ethernet/intel/e1000e/82571.c        |    3 +-
 drivers/net/ethernet/intel/e1000e/e1000.h        |   37 +++++++++
 drivers/net/ethernet/intel/e1000e/hw.h           |   10 ---
 drivers/net/ethernet/intel/e1000e/ich8lan.c      |   11 +++
 drivers/net/ethernet/intel/e1000e/netdev.c       |   51 ++++---------
 drivers/net/ethernet/intel/igb/igb_main.c        |    7 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |    2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   51 +-----------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |   88 ++++++++++++++--------
 10 files changed, 143 insertions(+), 125 deletions(-)

-- 
1.7.7.6
