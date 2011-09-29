From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/8][pull request] Intel Wired LAN Drivers Update
Date: Wed, 28 Sep 2011 23:30:08 -0700
Message-ID: <1317277816-6024-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:37696 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751175Ab1I2GaU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Sep 2011 02:30:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to e1000, ixgbe and ixgbevf.  This
series is missing the if_link and ixgbe patches for the additional
parameter for spoof checking, since Greg is re-working those patches
currently.

The following are changes since commit 2e1143742789463c00ed5e7f9bf471f2b707b493:
  candev: allow SJW user setting for bittiming calculation
and are available in the git repository at:
  git://github.com/Jkirsher/net-next.git

Dean Nelson (1):
  e1000: don't enable dma receives until after dma address has been
    setup

Don Skidmore (2):
  ixgbe: cleanup ixgbe_setup_gpie() for X540
  ixgbe: add ECC warning for legacy interrupts

Emil Tantilov (1):
  ixgbe: Cleanup q_vector interrupt throttle rate logic

Greg Rose (1):
  ixgbevf: Fix broken trunk vlan

Jacob Keller (1):
  ixgbe add thermal sensor support for x540 hardware

John Fastabend (1):
  ixgbe: update {P}FC thresholds to account for X540 and loopback

Vasu Dev (1):
  ixgbe: disable LLI for FCoE

 drivers/net/ethernet/intel/e1000/e1000_main.c      |    6 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h           |   25 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c     |    8 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c    |   12 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.h       |    1 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82598.c |    9 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c |    8 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c   |  153 ++++-------
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c      |    4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |  289 +++++++++++++++-----
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h      |   64 ++++-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c  |    6 +-
 12 files changed, 358 insertions(+), 227 deletions(-)

-- 
1.7.6.2
