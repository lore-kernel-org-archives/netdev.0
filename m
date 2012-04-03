From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/3][pull request] Intel Wired LAN Driver Updates
Date: Tue,  3 Apr 2012 15:28:56 -0700
Message-ID: <1333492139-32697-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:28712 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754516Ab2DCW3C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2012 18:29:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches contains fixes for ixgbe and e1000e.

The following are changes since commit 01627d968c8b5e2810fe8c417b406b968297c236:
  Merge branch 'drm-fixes-intel' of git://people.freedesktop.org/~airlied/linux
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Bruce Allan (1):
  e1000e: prevent oops when adapter is being closed and reset
    simultaneously

Matthew Vick (1):
  e1000e: Guarantee descriptor writeback flush success.

Multanen, Eric W (1):
  ixgbe: driver fix for link flap

 drivers/net/ethernet/intel/e1000e/e1000.h       |    6 +
 drivers/net/ethernet/intel/e1000e/netdev.c      |   26 ++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c |  164 +++++++++++------------
 3 files changed, 112 insertions(+), 84 deletions(-)

-- 
1.7.7.6
