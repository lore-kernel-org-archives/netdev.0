From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/5][pull request] Intel Wired LAN Driver Update
Date: Sat,  9 Jul 2011 04:50:35 -0700
Message-ID: <1310212240-24623-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:29537 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752981Ab1GILun (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2011 07:50:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to igb and ixgbe.

igb- a fix of adding a flush after a register write, the addition
    of SerDes forced mode support and a trivial update of copyright
    header.

ixgbe- conversion to ndo_fix_features and a fix to initialize
    fdir_perfect_lock in all cases

The following are changes since commit a05e42c27f80d341a5ec2053b041e24231a002e2:
  Merge branch 'for-davem' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6
and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6 master


Alexander Duyck (1):
  ixgbe: Make certain to initialize the fdir_perfect_lock in all cases

Carolyn Wyborny (3):
  igb: Fix lack of flush after register write and before delay
  igb: Update copyright on all igb driver files.
  igb: Add support of SerDes Forced mode for certain hardware

Don Skidmore (1):
  ixgbe: convert to ndo_fix_features

 drivers/net/igb/Makefile          |    2 +-
 drivers/net/igb/e1000_82575.c     |   22 ++++-
 drivers/net/igb/e1000_82575.h     |    4 +-
 drivers/net/igb/e1000_defines.h   |    7 +-
 drivers/net/igb/e1000_hw.h        |    2 +-
 drivers/net/igb/e1000_mac.c       |    2 +-
 drivers/net/igb/e1000_mac.h       |    2 +-
 drivers/net/igb/e1000_mbx.c       |    2 +-
 drivers/net/igb/e1000_mbx.h       |    2 +-
 drivers/net/igb/e1000_nvm.c       |    2 +-
 drivers/net/igb/e1000_nvm.h       |    2 +-
 drivers/net/igb/e1000_phy.c       |    2 +-
 drivers/net/igb/e1000_phy.h       |    2 +-
 drivers/net/igb/e1000_regs.h      |    2 +-
 drivers/net/igb/igb.h             |    2 +-
 drivers/net/igb/igb_ethtool.c     |    2 +-
 drivers/net/igb/igb_main.c        |    2 +-
 drivers/net/ixgbe/ixgbe.h         |    1 +
 drivers/net/ixgbe/ixgbe_ethtool.c |  188 -------------------------------------
 drivers/net/ixgbe/ixgbe_main.c    |  110 ++++++++++++++++++++--
 20 files changed, 142 insertions(+), 218 deletions(-)

-- 
1.7.6

