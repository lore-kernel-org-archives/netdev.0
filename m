From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/6][pull request] Intel Wired LAN Driver Updates
Date: Mon, 17 Sep 2012 02:21:43 -0700
Message-ID: <1347873709-2190-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net, matthew.vick@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:3469 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754096Ab2IQJVv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Sep 2012 05:21:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to igb, specifically the PTP code.
There have been no changes since the last pull request other than
the update to the git tree to the latest net-next.

There was discussion on patch 4 of the series which resulted in
a suggested change to the PTP core.  Once these get accepted,
Matthew Vick will continue on with the suggested changes made by
Richard Cochran, Ben Hutchings and Jacob Keller.
  
The following are changes since commit ba01dfe18241bf89b058fd8a60218b218ad2bb30:
  Merge branch 'for-davem' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Matthew Vick (6):
  igb: Tidy up wrapping for CONFIG_IGB_PTP.
  igb: Update PTP function names/variables and locations.
  igb: Correct PTP support query from ethtool.
  igb: Store the MAC address in the name in the PTP struct.
  igb: Prevent dropped Tx timestamps via work items and interrupts.
  igb: Add 1588 support to I210/I211.

 drivers/net/ethernet/intel/igb/e1000_defines.h |   8 +
 drivers/net/ethernet/intel/igb/e1000_regs.h    |   2 +
 drivers/net/ethernet/intel/igb/igb.h           |  29 +-
 drivers/net/ethernet/intel/igb/igb_ethtool.c   |  84 +--
 drivers/net/ethernet/intel/igb/igb_main.c      | 329 +++---------
 drivers/net/ethernet/intel/igb/igb_ptp.c       | 676 ++++++++++++++++++++-----
 6 files changed, 708 insertions(+), 420 deletions(-)

-- 
1.7.11.4
