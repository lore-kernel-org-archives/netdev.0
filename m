From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 v2 0/7][pull request] Intel Wired LAN Driver Updates
Date: Fri, 28 Jan 2011 04:28:56 -0800
Message-ID: <1296217743-30093-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:55113 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754897Ab1A1M3H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jan 2011 07:29:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains the addition of a PHY id for e1000
and several ixgbe fixes.

v2- fixed tab/space issue in patch 3 of series

The following are changes since commit 8f2771f2b85aea4d0f9a0137ad3b63d1173c0962:
  ipv6: Remove route peer binding assertions.

and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-2.6 master

Alexander Duyck (1):
  ixgbe: limit VF access to network traffic

Amir Hanania (1):
  ixgbe: DDP last buffer size work around

Don Skidmore (3):
  ixgbe: fix for 82599 erratum on Header Splitting.
  ixgbe: cleanup variable initialization
  ixgbe: update version string

Emil Tantilov (1):
  ixgbe: fix variable set but not used warnings by gcc 4.6

Florian Fainelli (1):
  e1000: add support for Marvell Alaska M88E1118R PHY

 drivers/net/e1000/e1000_hw.c     |    4 +++-
 drivers/net/e1000/e1000_hw.h     |    1 +
 drivers/net/ixgbe/ixgbe_common.c |    3 +++
 drivers/net/ixgbe/ixgbe_fcoe.c   |   21 ++++++++++++++++++++-
 drivers/net/ixgbe/ixgbe_main.c   |   16 ++++++++++------
 drivers/net/ixgbe/ixgbe_sriov.c  |    2 --
 drivers/net/ixgbe/ixgbe_x540.c   |    6 +++---
 7 files changed, 40 insertions(+), 13 deletions(-)

-- 
1.7.3.5

