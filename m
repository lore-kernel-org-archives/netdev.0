From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/6][pull request] Intel Wired LAN Driver Updates
Date: Wed,  5 Sep 2012 16:35:00 -0700
Message-ID: <1346888106-25638-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:43704 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759919Ab2IEXfJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Sep 2012 19:35:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to igb (specifically PTP code).

The following are changes since commit f6fe569fe056388166575af1cfaed0bcbc688305:
  Revert "usbnet: drop unneeded check for NULL"
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
