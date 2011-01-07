From: jeffrey.t.kirsher@intel.com
Subject: [net-next 00/12][pull-request] Intel Wired LAN Driver Updates
Date: Thu,  6 Jan 2011 16:29:47 -0800
Message-ID: <1294360199-9860-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gosp@redhat.com, bphilips@novell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:61497 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752727Ab1AGAaP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jan 2011 19:30:15 -0500
To: davem@davemloft.net
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

The following series contains ixgbe/e1000e cleanups and fixes.  The
addition of CE4100 support in e1000, and ixgb VLAN conversion to the
new model.

The following changes since commit dbbe68bb12b34f3e450da7a73c20e6fa1f85d63a:

  Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6.git master

Alexander Duyck (3):
  ixgbe: cleanup flow director hash computation to improve performance
  ixgbe: further flow director performance optimizations
  ixgbe: update ntuple filter configuration

Bruce Allan (6):
  e1000e: cleanup variables set but not used
  e1000e: convert calls of ops.[read|write]_reg to e1e_[r|w]phy
  e1000e: properly bounds-check string functions
  e1000e: use either_crc_le() rather than re-write it
  e1000e: power off PHY after reset when interface is down
  e1000e: add custom set_d[0|3]_lplu_state function pointer for 82574

Dirk Brandewie (1):
  e1000: Add support for the CE4100 reference platform

Emil Tantilov (1):
  ixgb: convert to new VLAN model

Yi Zou (1):
  ixgbe: make sure per Rx queue is disabled before unmapping the
    receive buffer

 drivers/net/e1000/e1000_hw.c      |  328 +++++++++++++----
 drivers/net/e1000/e1000_hw.h      |   59 +++-
 drivers/net/e1000/e1000_main.c    |   35 ++
 drivers/net/e1000/e1000_osdep.h   |   19 +-
 drivers/net/e1000e/82571.c        |   77 ++++-
 drivers/net/e1000e/e1000.h        |    3 +
 drivers/net/e1000e/es2lan.c       |    4 +-
 drivers/net/e1000e/ethtool.c      |   54 ++-
 drivers/net/e1000e/hw.h           |    1 +
 drivers/net/e1000e/ich8lan.c      |   77 ++---
 drivers/net/e1000e/lib.c          |    3 +-
 drivers/net/e1000e/netdev.c       |   53 ++--
 drivers/net/e1000e/phy.c          |   40 +--
 drivers/net/ixgb/ixgb.h           |    2 +-
 drivers/net/ixgb/ixgb_ethtool.c   |   35 ++
 drivers/net/ixgb/ixgb_main.c      |   54 +--
 drivers/net/ixgbe/ixgbe.h         |   21 +-
 drivers/net/ixgbe/ixgbe_82599.c   |  749 +++++++++++++++----------------------
 drivers/net/ixgbe/ixgbe_ethtool.c |  142 +++++---
 drivers/net/ixgbe/ixgbe_main.c    |  169 ++++++---
 drivers/net/ixgbe/ixgbe_type.h    |   91 +++--
 21 files changed, 1182 insertions(+), 834 deletions(-)

-- 
1.7.3.4

