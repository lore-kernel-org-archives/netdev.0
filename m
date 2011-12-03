From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/6][pull request] Intel Wired LAN Driver Updates
Date: Sat,  3 Dec 2011 03:44:25 -0800
Message-ID: <1322912671-6903-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:29132 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754513Ab1LCLoe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Dec 2011 06:44:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to e1000e, igb and ixgbe.  5 of
the patches are bug fixes and one patch is to cleanup a function
prototype of a non-existent function.

The following are changes since commit 340e8dc1fb4032b6c8334c9bff20b2aec42ecfd8:
  atm: clip: Remove code commented out since eternity.
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Bruce Allan (1):
  e1000e: hitting BUG_ON() from napi_enable

Greg Rose (1):
  ixgbe: Remove function prototype for non-existent function

John Fastabend (2):
  ixgbe: DCBnl set_all, order of operations fix
  ixgbe: DCB: IEEE transitions may fail to reprogram hardware.

Matthew Vick (1):
  igb: Update DMA Coalescing threshold calculation.

Michael Wang (1):
  e1000e: Avoid wrong check on TX hang

 drivers/net/ethernet/intel/e1000e/e1000.h       |    1 +
 drivers/net/ethernet/intel/e1000e/netdev.c      |   27 +++++-
 drivers/net/ethernet/intel/igb/igb_main.c       |   26 +++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c |   96 +++++++++--------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h  |    1 -
 5 files changed, 80 insertions(+), 71 deletions(-)

-- 
1.7.6.4
