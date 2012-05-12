From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 0/2][pull request] Intel Wired LAN Driver Updates
Date: Sat, 12 May 2012 02:11:56 -0700
Message-ID: <1336813918-11725-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:15548 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752577Ab2ELJMA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 May 2012 05:12:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches contains updates for igb.  Most notably,
the addition of i210 & i211 support.

v2: fix up patch 2 based on feedback from David Miller

The following are changes since commit 06a4c1c55dbe5d9f7a708e8f1a52fd2ac8e5874f:
  6lowpan: IPv6 link local address
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Carolyn Wyborny (2):
  igb: Add function and pointers for 82580 low power state settings.
  igb: Add Support for new i210/i211 devices.

 drivers/net/ethernet/intel/igb/Makefile        |    3 +-
 drivers/net/ethernet/intel/igb/e1000_82575.c   |  276 +++++++++--
 drivers/net/ethernet/intel/igb/e1000_82575.h   |    3 +-
 drivers/net/ethernet/intel/igb/e1000_defines.h |   33 ++
 drivers/net/ethernet/intel/igb/e1000_hw.h      |   14 +
 drivers/net/ethernet/intel/igb/e1000_i210.c    |  603 ++++++++++++++++++++++++
 drivers/net/ethernet/intel/igb/e1000_i210.h    |   76 +++
 drivers/net/ethernet/intel/igb/e1000_mac.c     |    1 +
 drivers/net/ethernet/intel/igb/e1000_nvm.c     |    1 -
 drivers/net/ethernet/intel/igb/e1000_phy.c     |  147 ++++++-
 drivers/net/ethernet/intel/igb/e1000_phy.h     |   22 +
 drivers/net/ethernet/intel/igb/e1000_regs.h    |   14 +
 drivers/net/ethernet/intel/igb/igb.h           |    9 +-
 drivers/net/ethernet/intel/igb/igb_ethtool.c   |  103 +++-
 drivers/net/ethernet/intel/igb/igb_main.c      |   81 +++-
 drivers/net/ethernet/intel/igb/igb_ptp.c       |    4 +
 16 files changed, 1293 insertions(+), 97 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/igb/e1000_i210.c
 create mode 100644 drivers/net/ethernet/intel/igb/e1000_i210.h

-- 
1.7.7.6
