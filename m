From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/5][pull request] Intel Wired LAN Driver Updates
Date: Tue,  3 Apr 2012 15:18:04 -0700
Message-ID: <1333491489-29933-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:49249 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753502Ab2DCWSL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2012 18:18:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches contains fixes for ixgbe and e1000e.
This also contains the last bit for e1000 to support RXALL flag
from Ben Greear.

The following are changes since commit 01627d968c8b5e2810fe8c417b406b968297c236:
  Merge branch 'drm-fixes-intel' of git://people.freedesktop.org/~airlied/linux
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Ben Greear (1):
  e1000: Support RX-ALL flag.

Bruce Allan (1):
  e1000e: prevent oops when adapter is being closed and reset
    simultaneously

Matthew Vick (2):
  e1000e: Guarantee descriptor writeback flush success.
  e1000e: Minor comment clean-up.

Multanen, Eric W (1):
  ixgbe: driver fix for link flap

 drivers/net/ethernet/intel/e1000/e1000_main.c   |   26 ++++-
 drivers/net/ethernet/intel/e1000e/e1000.h       |    6 +
 drivers/net/ethernet/intel/e1000e/netdev.c      |   29 ++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c |  164 +++++++++++------------
 4 files changed, 139 insertions(+), 86 deletions(-)

-- 
1.7.7.6
