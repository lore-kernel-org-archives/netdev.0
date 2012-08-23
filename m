From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/13][pull request] Intel Wired LAN Driver Updates
Date: Thu, 23 Aug 2012 02:56:40 -0700
Message-ID: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:59883 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756059Ab2HWJ44 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2012 05:56:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000 and igb.  Patches for e1000
consist of code cleanups and patches for igb adds loopback support
for i210 as well as PTP fixes.

The following are changes since commit 0fa7fa98dbcc2789409ed24e885485e645803d7f:
  packet: Protect packet sk list with mutex (v2)
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Bruce Allan (7):
  e1000e: use correct type for read of 32-bit register
  e1000e: cleanup strict checkpatch check
  e1000e: cleanup - remove inapplicable comment
  e1000e: cleanup checkpatch PREFER_PR_LEVEL warning
  e1000e: cleanup - remove unnecessary variable
  e1000e: update driver version number
  e1000e: cleanup strict checkpatch MEMORY_BARRIER checks

Carolyn Wyborny (1):
  igb: Add loopback test support for i210.

Eric Dumazet (1):
  igb: reduce Rx header size

Matthew Vick (4):
  igb: Tidy up wrapping for CONFIG_IGB_PTP.
  igb: Update PTP function names/variables and locations.
  igb: Correct PTP support query from ethtool.
  igb: Store the MAC address in the name in the PTP struct.

 drivers/net/ethernet/intel/e1000e/82571.c    |   4 +-
 drivers/net/ethernet/intel/e1000e/ethtool.c  |   3 +-
 drivers/net/ethernet/intel/e1000e/netdev.c   |  28 +-
 drivers/net/ethernet/intel/igb/igb.h         |  29 +-
 drivers/net/ethernet/intel/igb/igb_ethtool.c | 136 ++++----
 drivers/net/ethernet/intel/igb/igb_main.c    | 272 +--------------
 drivers/net/ethernet/intel/igb/igb_ptp.c     | 488 ++++++++++++++++++++-------
 7 files changed, 490 insertions(+), 470 deletions(-)

-- 
1.7.11.4
