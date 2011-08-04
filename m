From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/6][pull request] Intel Wired LAN Driver Update
Date: Thu,  4 Aug 2011 05:18:12 -0700
Message-ID: <1312460298-20405-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:1910 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752764Ab1HDMSi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Aug 2011 08:18:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to e1000, e1000e, igb, igbvf,
ixgb and ixgbe.

The following are changes since commit d3e614577198757d5854caa912e88f2d4296479b:
  macb: restore wrap bit when performing underrun cleanup
and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net master

Bruce Allan (2):
  e1000e: remove unnecessary check for NULL pointer
  e1000e: minor re-order of #include files

Carolyn Wyborny (1):
  igb: fix WOL on second port of i350 device

Don Skidmore (1):
  ixgbe: fix __ixgbe_notify_dca() bail out code

Emil Tantilov (1):
  ixgbe: fix PHY link setup for 82599

Jesse Brandeburg (1):
  intel drivers: repair missing flush operations

 drivers/net/e1000/e1000_ethtool.c |    6 ++++++
 drivers/net/e1000/e1000_hw.c      |    3 +++
 drivers/net/e1000e/es2lan.c       |    2 ++
 drivers/net/e1000e/ethtool.c      |   11 ++++++++++-
 drivers/net/e1000e/ich8lan.c      |    7 +++++--
 drivers/net/e1000e/lib.c          |    1 +
 drivers/net/e1000e/netdev.c       |    2 +-
 drivers/net/e1000e/phy.c          |    2 ++
 drivers/net/igb/e1000_nvm.c       |    1 +
 drivers/net/igb/igb_ethtool.c     |    5 +++++
 drivers/net/igb/igb_main.c        |    4 +++-
 drivers/net/igbvf/netdev.c        |    2 ++
 drivers/net/ixgb/ixgb_ee.c        |    9 +++++++++
 drivers/net/ixgb/ixgb_hw.c        |    2 ++
 drivers/net/ixgbe/ixgbe_82599.c   |    1 +
 drivers/net/ixgbe/ixgbe_common.c  |    1 +
 drivers/net/ixgbe/ixgbe_ethtool.c |    5 +++++
 drivers/net/ixgbe/ixgbe_main.c    |    3 ++-
 drivers/net/ixgbe/ixgbe_phy.c     |    3 +++
 drivers/net/ixgbe/ixgbe_x540.c    |    1 +
 20 files changed, 65 insertions(+), 6 deletions(-)

-- 
1.7.6

