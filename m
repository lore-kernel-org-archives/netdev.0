From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/2][pull request] Intel Wired LAN Driver Updates
Date: Tue, 24 Apr 2012 22:55:12 -0700
Message-ID: <1335333314-6814-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:63052 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758906Ab2DYFzQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2012 01:55:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches contains fixes for e1000e only.

The following are changes since commit 2a5809499e35b53a6044fd34e72b242688b7a862:
  asix: Fix tx transfer padding for full-speed USB
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Jeff Kirsher (1):
  e1000e: Fix default interrupt throttle rate not set in NIC HW

Prasanna S Panchamukhi (1):
  e1000e: MSI interrupt test failed, using legacy interrupt

 drivers/net/ethernet/intel/e1000e/netdev.c |    2 +-
 drivers/net/ethernet/intel/e1000e/param.c  |   99 +++++++++++++++-------------
 2 files changed, 54 insertions(+), 47 deletions(-)

-- 
1.7.7.6
