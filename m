From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/10][pull request] Intel Wired LAN Driver Update
Date: Thu, 21 Jul 2011 19:01:08 -0700
Message-ID: <1311300078-12876-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:44276 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751587Ab1GVCBV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jul 2011 22:01:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to e1000, igb and ixgbe.

The following are changes since commit 557e2a394de0d142ba930ff3cdb2909419414e06:
  stmmac: improve and up-to-date the documentation
and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6 master

Alexander Duyck (5):
  ixgbe: Update ATR to use recorded TX queues instead of CPU for
    routing
  ixgbe: inline the ixgbe_maybe_stop_tx function
  ixgbe: add structure for containing RX/TX rings to q_vector
  ixgbe: Move interrupt related values out of ring and into q_vector
  ixgbe: Pass staterr instead of re-reading status and error bits from
    descriptor

Andy Gospodarek (1):
  ixgbe: only enable WoL for magic packet by default

Don Skidmore (1):
  ixgbe: convert to ndo_fix_features

Emil Tantilov (1):
  ixgbe: remove ifdef check for non-existent define

Nicolas Schichan (1):
  e1000: always call e1000_check_for_link() on e1000_ce4100 MACs.

Robert Healy (1):
  igb: Fix for DH89xxCC near end loopback test

 drivers/net/e1000/e1000_main.c    |   11 +-
 drivers/net/igb/e1000_defines.h   |   10 +
 drivers/net/igb/igb_ethtool.c     |   33 +++
 drivers/net/ixgbe/ixgbe.h         |   50 ++--
 drivers/net/ixgbe/ixgbe_ethtool.c |  200 +---------------
 drivers/net/ixgbe/ixgbe_fcoe.c    |   35 +---
 drivers/net/ixgbe/ixgbe_main.c    |  480 +++++++++++++++++++------------------
 7 files changed, 338 insertions(+), 481 deletions(-)

-- 
1.7.6

