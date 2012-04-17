From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/2][pull request] Intel Wired LAN Driver Updates
Date: Tue, 17 Apr 2012 15:48:03 -0700
Message-ID: <1334702885-4411-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:60035 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751469Ab2DQWsI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Apr 2012 18:48:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches contains fixes for ixgbe only.

The following are changes since commit a99ff7d0123b19ecad3b589480b6542716ab6b52:
  net: usb: smsc75xx: fix mtu
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Alexander Duyck (1):
  ixgbe: Identify FCoE rings earlier to resolve memory corruption w/
    FCoE

Benjamin Poirier (1):
  ixgbe: add missing rtnl_lock in PM resume path

 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c  |   10 ++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   10 ++--------
 2 files changed, 12 insertions(+), 8 deletions(-)

-- 
1.7.7.6
