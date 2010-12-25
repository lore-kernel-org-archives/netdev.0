From: jeffrey.t.kirsher@intel.com
Subject: [net-next-2.6 00/15][pull-request] Intel Wired LAN Driver Update
Date: Fri, 24 Dec 2010 22:05:59 -0800
Message-ID: <1293257174-15498-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:17937 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751090Ab0LYGIf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Dec 2010 01:08:35 -0500
To: davem@davemloft.net
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

The following series addresses the more significant issues reported by
checkpatch when run against the e1000e driver files.  The less serious
whitespace and lines over 80 characters issues are not addressed.  In
addition, added support for anti-spoofing and X540 SR-IOV.

The remaining warnings for msleep < 20ms will be addressed in a follow-on
patch after a thorough investigation into the timings tolerated by the
hardware.

The following changes since commit e1928c86c4829703b800c81cc9edc939b5634e6f:

 cnic: Add FCoE support on 57712

are available in the git repository at:

 master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6.git master

Alexander Duyck (1):
  igbvf: force link checking when mailbox timeout has occurred

Bruce Allan (4):
  e1000e: checkpatch error - macro panethesis
  e1000e: checkpatch error - trailing statements
  e1000e: checkpatch error - open braces
  e1000e: checkpatch warnings - braces

Gasparakis, Joseph (1):
  igb: Some fine tuning

Greg Rose (7):
  igb: Fix overwrite of the VF's flags
  igb: Warn on attempt to override administratively set MAC/VLAN
  igb: Add Anti-spoofing feature support
  ixgbe: Warn on VF attempt to override Administratively set MAC/VLAN
  ixgbe: Add SR-IOV feature support to X540
  ixgbe: Add anti-spoofing feature support
  ixgbevf: Add X540 VF device support to the ixgbevf driver

Jeff Kirsher (1):
  Documentation/networking: Update Intel Wired LAN docs

Williams, Mitch A (1):
  igbvf: add support for i350 VF device

 Documentation/networking/e100.txt   |   19 ++----
 Documentation/networking/e1000.txt  |    6 +-
 Documentation/networking/e1000e.txt |   14 ++--
 Documentation/networking/igb.txt    |    6 +-
 Documentation/networking/igbvf.txt  |    4 +-
 Documentation/networking/ixgb.txt   |   10 ++--
 Documentation/networking/ixgbe.txt  |    8 +-
 drivers/net/e1000e/es2lan.c         |    8 +-
 drivers/net/e1000e/ethtool.c        |  118 ++++++++++++++++++-----------------
 drivers/net/e1000e/ich8lan.c        |    5 +-
 drivers/net/e1000e/lib.c            |    6 +-
 drivers/net/e1000e/netdev.c         |   21 +++----
 drivers/net/e1000e/phy.c            |   25 ++++----
 drivers/net/igb/e1000_82575.c       |   37 +++++++++++-
 drivers/net/igb/e1000_82575.h       |    5 ++
 drivers/net/igb/e1000_hw.h          |    6 +-
 drivers/net/igb/e1000_regs.h        |    1 +
 drivers/net/igb/igb.h               |    1 +
 drivers/net/igb/igb_main.c          |   74 ++++++++++++++++++++--
 drivers/net/igbvf/igbvf.h           |    1 +
 drivers/net/igbvf/netdev.c          |    9 +++
 drivers/net/igbvf/vf.c              |    4 +-
 drivers/net/igbvf/vf.h              |    2 +
 drivers/net/ixgbe/ixgbe_82599.c     |    2 +
 drivers/net/ixgbe/ixgbe_common.c    |   64 +++++++++++++++++++
 drivers/net/ixgbe/ixgbe_common.h    |    2 +
 drivers/net/ixgbe/ixgbe_main.c      |   26 +++++++-
 drivers/net/ixgbe/ixgbe_mbx.c       |    4 +-
 drivers/net/ixgbe/ixgbe_sriov.c     |   52 ++++++++++++----
 drivers/net/ixgbe/ixgbe_type.h      |   13 ++++-
 drivers/net/ixgbe/ixgbe_x540.c      |    2 +
 drivers/net/ixgbevf/defines.h       |    1 +
 drivers/net/ixgbevf/ixgbevf.h       |    4 +-
 drivers/net/ixgbevf/ixgbevf_main.c  |    7 ++-
 drivers/net/ixgbevf/vf.c            |    6 ++-
 drivers/net/ixgbevf/vf.h            |    1 +
 36 files changed, 410 insertions(+), 164 deletions(-)

-- 
1.7.3.4

