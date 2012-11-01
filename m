From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/6][pull request] Intel Wired LAN Driver Updates
Date: Thu,  1 Nov 2012 03:44:21 -0700
Message-ID: <1351766667-28489-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:51802 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756174Ab2KAKob (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2012 06:44:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to igb, ixgbe and e1000.

The following are changes since commit 810b6d7638a288216f99bd190470d67061c8bd88:
  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Carolyn Wyborny (3):
  igb: Remove workaround for EEE configuration on i210/I211
  igb: Add function to read i211's invm version
  igb: Fix EEPROM writes via ethtool on i210

Emil Tantilov (1):
  ixgbe: fix default setting of TXDCTL.WTHRESH

Jacob Keller (1):
  ixgbe: fix uninitialized event.type in ixgbe_ptp_check_pps_event

Maxime Bizon (1):
  e1000: fix concurrent accesses to PHY from watchdog and ethtool

 drivers/net/ethernet/intel/e1000/e1000_hw.c   | 17 ++++-
 drivers/net/ethernet/intel/igb/e1000_82575.c  | 20 +++---
 drivers/net/ethernet/intel/igb/e1000_i210.c   | 94 +++++++++++++++++++++++++++
 drivers/net/ethernet/intel/igb/e1000_i210.h   | 11 ++++
 drivers/net/ethernet/intel/igb/e1000_mac.h    |  1 +
 drivers/net/ethernet/intel/igb/e1000_nvm.c    |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c  | 15 +++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 20 ------
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c  |  9 +++
 9 files changed, 155 insertions(+), 33 deletions(-)

-- 
1.7.11.7
