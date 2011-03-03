From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 00/24][pull request] Intel Wired LAN Driver Updates
Date: Thu,  3 Mar 2011 05:03:25 -0800
Message-ID: <1299157429-15878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:51571 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757104Ab1CCNES (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 08:04:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains cleanups and fixes for igb, ixgbevf
and mainly ixgbe.

The following are changes since commit dc6ed1df5a5f84e45e77e2acb6fd99b995414956:
  dcbnl: add support for retrieving peer configuration - cee

and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6 master

Alexander Duyck (1):
  ixgbe: balance free_irq calls with request_irq calls

Carolyn Wyborny (2):
  igb: Fix reg pattern test in ethtool for i350 devices
  igb: Fix strncpy calls to be safe per source code review tools

Don Skidmore (3):
  ixgbe: cleanup X540 PHY reset function pointer
  ixgbe: add function pointer for semaphore function
  ixgbe: cleanup copyright string for 2011

Emil Tantilov (15):
  ixgbe: cleanup wake on LAN defines
  ixgbe: cleanup logic related to HW semaphores
  ixgbe: set media type for 82599 T3 LOM
  ixgbe: Add ability to double reset on failure to clear master enable
  ixgbe: cleanup code in ixgbe_identify_sfp_module_generic
  ixgbe: Check link wants report current link state
  ixgbe: add polling test to end of PHY reset
  ixgbe: Fill out PCIe speed and width enums with values
  ixgbe: Bounds checking for set_rar, clear_rar, set_vmdq, clear_vmdq
  ixgbe: rework ixgbe MTA handling to not drop packets
  ixgbe: Drop unused code for setting up unicast addresses
  ixgbe: Specific check for 100 Full link speed
  ixgbe: Numerous whitespace / formatting cleanups
  ixgbe: store permanent address before initializing Rx addresses
  ixgbe: cleanup handling of I2C interface to PHY

Greg Rose (2):
  ixgbevf: Fix Compiler Warnings
  ixgbe: X540 Cleanup

Stefan Assmann (1):
  igb: warn if max_vfs limit is exceeded

 drivers/net/igb/igb_ethtool.c       |   13 +-
 drivers/net/igb/igb_main.c          |    7 +-
 drivers/net/ixgbe/ixgbe.h           |    2 +-
 drivers/net/ixgbe/ixgbe_82598.c     |   63 ++++--
 drivers/net/ixgbe/ixgbe_82599.c     |  104 ++++++---
 drivers/net/ixgbe/ixgbe_common.c    |  438 ++++++++++++++---------------------
 drivers/net/ixgbe/ixgbe_common.h    |    4 +-
 drivers/net/ixgbe/ixgbe_dcb.c       |    2 +-
 drivers/net/ixgbe/ixgbe_dcb.h       |    2 +-
 drivers/net/ixgbe/ixgbe_dcb_82598.c |    2 +-
 drivers/net/ixgbe/ixgbe_dcb_82598.h |    2 +-
 drivers/net/ixgbe/ixgbe_dcb_82599.c |    2 +-
 drivers/net/ixgbe/ixgbe_dcb_82599.h |    2 +-
 drivers/net/ixgbe/ixgbe_dcb_nl.c    |    2 +-
 drivers/net/ixgbe/ixgbe_ethtool.c   |    2 +-
 drivers/net/ixgbe/ixgbe_fcoe.c      |    2 +-
 drivers/net/ixgbe/ixgbe_fcoe.h      |    2 +-
 drivers/net/ixgbe/ixgbe_main.c      |   12 +-
 drivers/net/ixgbe/ixgbe_mbx.c       |    2 +-
 drivers/net/ixgbe/ixgbe_mbx.h       |    2 +-
 drivers/net/ixgbe/ixgbe_phy.c       |  238 ++++++++++++++-----
 drivers/net/ixgbe/ixgbe_phy.h       |    2 +-
 drivers/net/ixgbe/ixgbe_sriov.c     |    2 +-
 drivers/net/ixgbe/ixgbe_sriov.h     |    2 +-
 drivers/net/ixgbe/ixgbe_type.h      |   40 ++--
 drivers/net/ixgbe/ixgbe_x540.c      |   34 ++-
 drivers/net/ixgbevf/ixgbevf_main.c  |    9 +-
 27 files changed, 547 insertions(+), 447 deletions(-)

-- 
1.7.4

