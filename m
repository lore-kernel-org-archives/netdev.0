From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 0/7][pull request] Intel Wired LAN Driver Update
Date: Fri,  3 Feb 2012 03:14:56 -0800
Message-ID: <1328267703-9638-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:53720 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756069Ab2BCLPU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Feb 2012 06:15:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains fixes to igbvf, ixgbe and ixgbevf.
The fixes do the following:
 - update copyright
 - fix typo
 - fix sparse warnings
 - fix mailbox interrupt ACK bug

v2- Dropped the ixgbe namespace fix patch to find a better resolution
    based on feedback from David Miller.

The following are changes since commit 29830406415c227a54af429d7b300aabd4754237:
  can: peak_pci: Fix the way channels are linked together
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Don Skidmore (1):
  ixgbe: update copyright to 2012

Greg Rose (3):
  ixgbe: Add warning when no space left for more MAC filters
  ixgbevf: Fix mailbox interrupt ack bug
  ixgbevf: Update copyright notices

Masanari Iida (1):
  ixgbe: Fix typo in ixgbe_common.h

Mitch A Williams (1):
  igbvf: change copyright date

Stephen Hemminger (1):
  ixgbe: make ethtool strings table const

 drivers/net/ethernet/intel/igbvf/Makefile          |    2 +-
 drivers/net/ethernet/intel/igbvf/defines.h         |    2 +-
 drivers/net/ethernet/intel/igbvf/ethtool.c         |    2 +-
 drivers/net/ethernet/intel/igbvf/igbvf.h           |    2 +-
 drivers/net/ethernet/intel/igbvf/mbx.c             |    2 +-
 drivers/net/ethernet/intel/igbvf/mbx.h             |    2 +-
 drivers/net/ethernet/intel/igbvf/netdev.c          |    4 +-
 drivers/net/ethernet/intel/igbvf/regs.h            |    2 +-
 drivers/net/ethernet/intel/igbvf/vf.c              |    2 +-
 drivers/net/ethernet/intel/igbvf/vf.h              |    2 +-
 drivers/net/ethernet/intel/ixgbe/Makefile          |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h           |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c     |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c     |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c    |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h    |    4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c       |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.h       |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82598.c |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82598.h |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.h |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c    |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c   |    4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c      |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.h      |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |    4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c       |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h       |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c       |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h       |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c     |    5 +++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h     |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h      |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c      |    2 +-
 drivers/net/ethernet/intel/ixgbevf/Makefile        |    2 +-
 drivers/net/ethernet/intel/ixgbevf/defines.h       |    2 +-
 drivers/net/ethernet/intel/ixgbevf/ethtool.c       |    2 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h       |    2 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c  |   12 +++++++---
 drivers/net/ethernet/intel/ixgbevf/mbx.c           |    2 +-
 drivers/net/ethernet/intel/ixgbevf/mbx.h           |    2 +-
 drivers/net/ethernet/intel/ixgbevf/regs.h          |    2 +-
 drivers/net/ethernet/intel/ixgbevf/vf.c            |   21 +++++++++++++++----
 drivers/net/ethernet/intel/ixgbevf/vf.h            |    2 +-
 45 files changed, 74 insertions(+), 56 deletions(-)

-- 
1.7.7.6
