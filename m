From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/4][pull request] Intel Wired LAN Driver Updates
Date: Sat, 22 Jan 2011 03:56:12 -0800
Message-ID: <1295697376-2984-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:38728 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752733Ab1AVL4a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Jan 2011 06:56:30 -0500
To: David Miller <davem@davemloft.net>
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains cleanups for e1000e and addition support
for the i340 adapter in igb.

The following are changes since commit bb134d2298b49f50cf6d9388410fba96272905dc:
  net: netif_setup_tc() is static

and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6 master

Bruce Allan (2):
  e1000e: reduce scope of some variables, remove unnecessary ones
  e1000e: Use kmemdup rather than duplicating its implementation

Carolyn Wyborny (1):
  igb: Add support for i340 Quad Port Fiber Adapter

Jeff Kirsher (1):
  e1000e: convert to stats64

 drivers/net/e1000e/e1000.h    |    5 ++-
 drivers/net/e1000e/ethtool.c  |   52 ++++++++-----------
 drivers/net/e1000e/ich8lan.c  |    3 +-
 drivers/net/e1000e/lib.c      |    4 +-
 drivers/net/e1000e/netdev.c   |  117 +++++++++++++++++++++++++++-------------
 drivers/net/e1000e/phy.c      |    8 ++--
 drivers/net/igb/e1000_82575.c |    1 +
 drivers/net/igb/e1000_hw.h    |    1 +
 drivers/net/igb/igb_main.c    |    1 +
 9 files changed, 116 insertions(+), 76 deletions(-)

-- 
1.7.3.4

