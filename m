From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/4][pull request] Intel Wired LAN Driver Updates
Date: Sat,  5 May 2012 05:38:09 -0700
Message-ID: <1336221493-913-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:42294 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755401Ab2EEMiQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 May 2012 08:38:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches contains updates for e1000e and ixgbe.

NOTE- The ixgbe patch can and probably should be applied to
David Miller's net tree as well.

The following are changes since commit bd14b1b2e29bd6812597f896dde06eaf7c6d2f24:
  tcp: be more strict before accepting ECN negociation
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Bruce Allan (2):
  e1000e: enable forced master/slave on 82577
  e1000e: increase version number

John Fastabend (1):
  ixgbe: dcb: IEEE PFC stats and reset logic incorrect

Richard Alpe (1):
  e1000e: clear REQ and GNT in EECD (82571 && 82572)

 drivers/net/ethernet/intel/e1000e/82571.c       |   12 ++++-
 drivers/net/ethernet/intel/e1000e/netdev.c      |    2 +-
 drivers/net/ethernet/intel/e1000e/phy.c         |   71 ++++++++++++++--------
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c |    7 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |    6 ++-
 5 files changed, 69 insertions(+), 29 deletions(-)

-- 
1.7.7.6
