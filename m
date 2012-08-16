From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: [net-next 0/9][pull request] Intel Wired LAN Driver Updates
Date: Thu, 16 Aug 2012 15:48:29 -0700
Message-ID: <1345157318-23731-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Cc: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:12017 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755317Ab2HPWst (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Aug 2012 18:48:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains multiple updates to the ixgbe driver.

The following are changes since commit 02644a17457414f38e29f32d5c640b06d08fa092:
    sctp: fix bogus if statement in sctp_auth_recv_cid()
  
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/ppwaskie/net-next master

Alexander Duyck (9):
  ixgbe: Remove code that was initializing Rx page offset
  ixgbe: combine ixgbe_add_rx_frag and ixgbe_can_reuse_page
  ixgbe: Only use double buffering if page size is less than 8K
  ixgbe: Have the CPU take ownership of the buffers sooner
  ixgbe: Make pull tail function separate from rest of cleanup_headers
  ixgbe: Copybreak sooner to avoid get_page/put_page and offset change
    overhead
  ixgbe: Make allocating skb and placing data in it a separate function
  ixgbe: Roll RSC code into non-EOP code
  ixgbe: Rewrite code related to configuring IFCS bit in Tx descriptor

 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |  25 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 497 ++++++++++++++------------
 2 files changed, 284 insertions(+), 238 deletions(-)

-- 
1.7.11.2
