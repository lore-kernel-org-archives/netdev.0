From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/8][pull request] Intel Wired LAN Driver Update
Date: Wed,  4 Apr 2012 00:55:52 -0700
Message-ID: <1333526160-24937-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:39155 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754391Ab2DDH4D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2012 03:56:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches contains updates for e1000, e1000e, igb and
ixgbe.  The e1000 patch finishes up the addition of RXALL support
flag from Ben Greear.  The 2 igb patches adds the PTP support
from Richard Cochran.  The remaining patches for e1000e and ixgbe
are cleanup patches (and rev the e1000e driver).

The following are changes since commit 68df25d6c556c4df4dad32a0585317eab356e325:
  bnx2x: Change to driver version 1.72.10-0
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Ben Greear (1):
  e1000: Support RX-ALL flag.

Bruce Allan (3):
  e1000e: cleanup NAPI routine
  e1000e: cleanup indexed register arrays
  e1000e: update driver version number

Emil Tantilov (1):
  ixgbe: consolidate reporting of MSIX vectors into a single function

Matthew Vick (1):
  e1000e: Minor comment clean-up.

Richard Cochran (2):
  igb: add PTP Hardware Clock code
  igb: offer a PTP Hardware Clock instead of the timecompare method

 drivers/net/ethernet/intel/Kconfig              |   11 +
 drivers/net/ethernet/intel/e1000/e1000_main.c   |   26 ++-
 drivers/net/ethernet/intel/e1000e/ethtool.c     |   52 ++--
 drivers/net/ethernet/intel/e1000e/hw.h          |   47 ++--
 drivers/net/ethernet/intel/e1000e/netdev.c      |   81 +++---
 drivers/net/ethernet/intel/igb/Makefile         |    1 +
 drivers/net/ethernet/intel/igb/igb.h            |   21 +-
 drivers/net/ethernet/intel/igb/igb_main.c       |  178 +----------
 drivers/net/ethernet/intel/igb/igb_ptp.c        |  381 +++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c  |   25 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c |   29 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h   |    4 +-
 13 files changed, 571 insertions(+), 287 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/igb/igb_ptp.c

-- 
1.7.7.6
