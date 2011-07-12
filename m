From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/4][pull request] Intel Wired LAN Driver Update
Date: Mon, 11 Jul 2011 19:15:10 -0700
Message-ID: <1310436914-4017-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:17366 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752938Ab1GLCPR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2011 22:15:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to igb and ixgbe.

igb- a fix of adding a flush after a register write, the addition
    of SerDes forced mode support and a trivial update of copyright
    header.

ixgbe- fix to initialize fdir_perfect_lock in all cases

Dropped the conversion to ndo_fix_features patch from Don Skidmore so that
Don can fix up the patch based on the suggestions from Michal Miroslaw
  
The following are changes since commit d84e0bd7971eb8357c700151ee4e8e4101ee65fa:
  skbuff: update struct sk_buff members comments
and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6 master

Alexander Duyck (1):
  ixgbe: Make certain to initialize the fdir_perfect_lock in all cases

Carolyn Wyborny (3):
  igb: Fix lack of flush after register write and before delay
  igb: Update copyright on all igb driver files.
  igb: Add support of SerDes Forced mode for certain hardware

 drivers/net/igb/Makefile        |    2 +-
 drivers/net/igb/e1000_82575.c   |   22 +++++++++++++++++++---
 drivers/net/igb/e1000_82575.h   |    4 +++-
 drivers/net/igb/e1000_defines.h |    7 ++++---
 drivers/net/igb/e1000_hw.h      |    2 +-
 drivers/net/igb/e1000_mac.c     |    2 +-
 drivers/net/igb/e1000_mac.h     |    2 +-
 drivers/net/igb/e1000_mbx.c     |    2 +-
 drivers/net/igb/e1000_mbx.h     |    2 +-
 drivers/net/igb/e1000_nvm.c     |    2 +-
 drivers/net/igb/e1000_nvm.h     |    2 +-
 drivers/net/igb/e1000_phy.c     |    2 +-
 drivers/net/igb/e1000_phy.h     |    2 +-
 drivers/net/igb/e1000_regs.h    |    2 +-
 drivers/net/igb/igb.h           |    2 +-
 drivers/net/igb/igb_ethtool.c   |    2 +-
 drivers/net/igb/igb_main.c      |    2 +-
 drivers/net/ixgbe/ixgbe_main.c  |    5 +++--
 18 files changed, 43 insertions(+), 23 deletions(-)

-- 
1.7.6

