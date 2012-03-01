From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/10][pull request] Intel Wired LAN Driver Updates
Date: Wed, 29 Feb 2012 23:32:58 -0800
Message-ID: <1330587188-28717-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:59674 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753784Ab2CAHdL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Mar 2012 02:33:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches contains fixes/cleanups/additions to e100, e1000e,
ixgbe & rtnetlink.  The e100 changes are from Ben Greear, which adds support
for low-level Ethernet debugging.  The e1000e & ixgbe changes are cleanups.
The only fix in the series is the rtnetlink patch from Greg Rose.

The following are changes since commit 06b8db9cac717fcd6b8410b9efae8aca33b4b9e6:
  Merge branch 'tipc_net-next' of git://git.kernel.org/pub/scm/linux/kernel/git/paulg/linux
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (2):
  ixgbe: Minor formatting and comment corrections for
    ixgbe_xmit_frame_ring
  ixgbe: Fix comments that are out of date or formatted incorrectly

Ben Greear (3):
  e100: Support RXFCS feature flag.
  e100: Support sending custom Ethernet CRC
  e100: Support RXALL feature flag.

Bruce Allan (3):
  e1000e: cleanup incorrect filename in comment
  e1000e: cleanup whitespace and indentation
  e1000e: use msleep instead of mdelay

Don Skidmore (1):
  ixgbe: fix spelling errors

Greg Rose (1):
  rtnetlink: Fix VF IFLA policy

 drivers/net/ethernet/intel/e100.c               |   71 +++++++++++++++++++++--
 drivers/net/ethernet/intel/e1000e/82571.c       |   14 ++---
 drivers/net/ethernet/intel/e1000e/ich8lan.c     |   10 +--
 drivers/net/ethernet/intel/e1000e/mac.c         |    2 +-
 drivers/net/ethernet/intel/e1000e/netdev.c      |   12 ++--
 drivers/net/ethernet/intel/e1000e/phy.c         |   63 +++++++-------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |   30 ++++++---
 net/core/rtnetlink.c                            |    2 +
 9 files changed, 128 insertions(+), 78 deletions(-)

-- 
1.7.7.6
