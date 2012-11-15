From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/9][pull request] Intel Wired LAN Driver Updates
Date: Thu, 15 Nov 2012 06:39:38 -0800
Message-ID: <1352990387-3872-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:53540 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2993283Ab2KOOjv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2012 09:39:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ioat (DCA) and ixgbevf.

The following are changes since commit 702ed3c1a9dfe4dfe112f13542d0c9d689f5008b:
  Merge tag 'batman-adv-for-davem' of git://git.open-mesh.org/linux-merge
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (1):
  ioat: Do not enable DCA if tag map is invalid

Greg Rose (8):
  ixgbevf: Streamline the rx buffer allocation
  ixgbevf: Fix unnecessary dereference where local var is available.
  ixgbevf: Remove the ring adapter pointer value
  ixgbevf: Remove checking for mac.ops function pointers
  ixgbevf: Remove mailbox spinlock from the reset function
  ixgbevf: White space and comments clean up
  ixgbevf: Remove unneeded and obsolete comment
  ixgbevf: Add checksum statistics counters to rings

 drivers/dma/ioat/dca.c                            |  23 ++++
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |   3 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 123 +++++++++-------------
 3 files changed, 72 insertions(+), 77 deletions(-)

-- 
1.7.11.7
