From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/3][pull request] Intel Wired LAN Driver Updates
Date: Mon, 30 Apr 2012 16:16:31 -0700
Message-ID: <1335827794-26992-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:48974 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756884Ab2D3XQg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2012 19:16:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches contains fixes for igbvf and ixgbe.

The following are changes since commit 1cebce36d660c83bd1353e41f3e66abd4686f215:
  tcp: fix infinite cwnd in tcp_complete_cwr()
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Alexander Duyck (1):
  ixgbe: Fix a memory leak in IEEE DCB

Shan Wei (1):
  igbvf: fix the bug when initializing the igbvf

Yi Zou (1):
  ixgbe: fix calling skb_put on nonlinear skb assertion bug

 drivers/net/ethernet/intel/igbvf/netdev.c     |    4 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c |    1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    9 +++++----
 3 files changed, 8 insertions(+), 6 deletions(-)

-- 
1.7.7.6
