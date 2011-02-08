From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 0/7][pull request] Intel Wired LAN Driver Updates
Date: Tue,  8 Feb 2011 01:44:32 -0800
Message-ID: <1297158279-20277-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:25861 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752160Ab1BHJon (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Feb 2011 04:44:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains the addition of a PHY id for e1000,
fix for e1000e, and several ixgbe fixes.

We are currently still working on the patch:
  ixgbe: DDP last buffer size work around
which was in the previous pull request, and has been removed from this
pull request.

The following are changes since commit 429a01a70f301baf0c8fc780f891a18c296d5e24:
  Merge branch 'batman-adv/merge' of git://git.open-mesh.org/ecsv/linux-merge

and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-2.6 master

Alexander Duyck (1):
  ixgbe: limit VF access to network traffic

Don Skidmore (3):
  ixgbe: fix for 82599 erratum on Header Splitting
  ixgbe: cleanup variable initialization
  ixgbe: update version string

Emil Tantilov (1):
  ixgbe: fix variable set but not used warnings by gcc 4.6

Florian Fainelli (1):
  e1000: add support for Marvell Alaska M88E1118R PHY

Jesse Brandeburg (1):
  e1000e: tx_timeout should not increment for non-hang events

 drivers/net/e1000/e1000_hw.c     |    4 +++-
 drivers/net/e1000/e1000_hw.h     |    1 +
 drivers/net/e1000e/netdev.c      |    1 -
 drivers/net/ixgbe/ixgbe_common.c |    3 +++
 drivers/net/ixgbe/ixgbe_fcoe.c   |    2 +-
 drivers/net/ixgbe/ixgbe_main.c   |   16 ++++++++++------
 drivers/net/ixgbe/ixgbe_sriov.c  |    2 --
 drivers/net/ixgbe/ixgbe_x540.c   |    6 +++---
 8 files changed, 21 insertions(+), 14 deletions(-)

-- 
1.7.4

