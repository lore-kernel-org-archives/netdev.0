From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/12][pull request] Intel Wired LAN Driver Updates
Date: Sat, 17 Mar 2012 01:50:48 -0700
Message-ID: <1331974260-6383-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:28252 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752070Ab2CQIv2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Mar 2012 04:51:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches contains additions/cleanups to igb and ixgbe.
There 2 patches for igb & ixgbe which add FX-ALL feature flag and
sending of custom Ethernet FCS from Ben Greear.

The remaining patches in the series is part three of three to update
ixgbe.  Although it looks like there will be at least one follow on
patch series complete the update/cleanup of ixgbe.

The following are changes since commit 126a3fd251b244eabd9ab9dcb32b8b6f999c1b91:
  eni: fix driver remove function and driver probe error path.
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (8):
  ixgbe: Replace standard receive path with a page based receive
  ixgbe: cleanup logic in ixgbe_change_mtu
  ixgbe: Make certain that all frames fit minimum size requirements
  ixgbe: Modify setup of descriptor flags to avoid conditional jumps
  ixgbe: Use packets to track Tx completions instead of a separate
    value
  ixgbe: Place skb on first buffer_info structure to avoid using stack
    space
  ixgbe: Write gso_segs and bytcount to the ring sooner
  ixgbe: always write DMA for single_mapped value with skb

Ben Greear (4):
  igb: Support sending custom Ethernet FCS.
  igb: Support RX-ALL feature flag.
  ixgbe: Support sending custom Ethernet FCS.
  ixgbe: Support RX-ALL feature flag.

 drivers/net/ethernet/intel/igb/e1000_defines.h   |    2 +
 drivers/net/ethernet/intel/igb/igb_main.c        |   37 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |   60 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   23 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c    |   17 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 1261 ++++++++++++----------
 6 files changed, 772 insertions(+), 628 deletions(-)

-- 
1.7.7.6
