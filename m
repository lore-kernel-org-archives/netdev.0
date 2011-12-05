From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/6 v2][pull request] Intel Wired LAN Driver Updates
Date: Mon,  5 Dec 2011 00:20:35 -0800
Message-ID: <1323073241-21144-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:55396 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752299Ab1LEIUp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Dec 2011 03:20:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to e1000e, igb and ixgbe.  5 of
the patches are bug fixes and one patch is to cleanup a function
prototype of a non-existent function.

-v2 fix up patch 1 based on David Miller's suggestion
    fix up patch 5 so that the tested-by is in the correct place

The following are changes since commit 340e8dc1fb4032b6c8334c9bff20b2aec42ecfd8:
  atm: clip: Remove code commented out since eternity.
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Bruce Allan (1):
  e1000e: hitting BUG_ON() from napi_enable

Greg Rose (1):
  ixgbe: Remove function prototype for non-existent function

Jeff Kirsher (1):
  e1000e: Avoid wrong check on TX hang

John Fastabend (2):
  ixgbe: DCBnl set_all, order of operations fix
  ixgbe: DCB: IEEE transitions may fail to reprogram hardware.

Matthew Vick (1):
  igb: Update DMA Coalescing threshold calculation.

 drivers/net/ethernet/intel/e1000e/e1000.h       |    1 +
 drivers/net/ethernet/intel/e1000e/netdev.c      |   27 +++++-
 drivers/net/ethernet/intel/igb/igb_main.c       |   26 +++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c |   96 +++++++++--------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h  |    1 -
 5 files changed, 80 insertions(+), 71 deletions(-)

-- 
1.7.6.4
