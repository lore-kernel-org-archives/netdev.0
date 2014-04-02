From: Jakub Kicinski <kubakici@wp.pl>
Subject: [PATCH net-next 0/4] intel: string and rx tstamping cleanups
Date: Wed,  2 Apr 2014 02:52:15 +0200
Message-ID: <1396399939-18420-1-git-send-email-kubakici@wp.pl>
Cc: Jakub Kicinski <kubakici@wp.pl>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.10]:51571 "EHLO mx3.wp.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751366AbaDBAxK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Apr 2014 20:53:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This series contains promised string fixes and small cleanups for rx time
stamping code in igb and ixgbe.

String cleanups are limited to new line termination. Joe Perches suggested
more improvements that seem worthwhile. [1]

Rx time stamping path in igb and ixgbe was redesigned few times in the past
and there are some small errors and leftovers from previous versions so 
I clean it up a little too.

     -- kuba

[1] http://www.spinics.net/lists/netdev/msg275288.html



Jakub Kicinski (4):
  e1000: remove debug messages with function names
  e1000e/igb/ixgbe/i40e: fix message terminations
  ixgbe: clean up rx time stamping code
  igb: fix last_rx_timestamp usage

 drivers/net/ethernet/intel/e1000/e1000_hw.c     | 124 ------------------------
 drivers/net/ethernet/intel/e1000e/netdev.c      |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_nvm.c      |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_ptp.c      |   4 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c     |   4 +-
 drivers/net/ethernet/intel/igb/e1000_i210.c     |   2 +-
 drivers/net/ethernet/intel/igb/e1000_mac.c      |  13 ++-
 drivers/net/ethernet/intel/igb/igb.h            |  16 +--
 drivers/net/ethernet/intel/igb/igb_main.c       |   4 +-
 drivers/net/ethernet/intel/igb/igb_ptp.c        |  18 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe.h        |  21 +---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |   3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c    |   6 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c    |  40 +++-----
 15 files changed, 47 insertions(+), 214 deletions(-)

--
1.9.0
