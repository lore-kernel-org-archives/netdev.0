From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/6][pull request] Intel Wired LAN Driver Updates
Date: Mon, 24 Sep 2012 02:00:01 -0700
Message-ID: <1348477207-27030-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:39455 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750970Ab2IXJAM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2012 05:00:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe and ixgbevf (mainly ixgbevf).

The following are changes since commit c9d2ea96ca3bbc85264803ff6bd66eb3bbefdb77:
  netlink: Rearrange netlink_kernel_cfg to save space on 64-bit.
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (3):
  ixgbevf: Fix code for handling timeout
  ixgbevf: Add fix to VF to handle multi-descriptor buffers
  ixgbevf: Return error on failure to enable VLAN

Greg Rose (2):
  ixgbe: Do not read the spoofed packets counter when not in IOV mode
  ixgbevf: Fix AIM (Adaptive Interrupt Moderation)

Narendra K (1):
  ixgbevf - Remove unused parameter in ixgbevf_receive_skb

 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |  5 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  5 ++
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 89 +++++++++++------------
 drivers/net/ethernet/intel/ixgbevf/mbx.c          | 15 +++-
 drivers/net/ethernet/intel/ixgbevf/vf.c           | 69 ++++++++++++++----
 5 files changed, 117 insertions(+), 66 deletions(-)

-- 
1.7.11.4
