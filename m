From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/2][pull request] Intel Wired LAN Driver Updates 2015-05-07
Date: Thu,  7 May 2015 05:21:31 -0700
Message-ID: <1431001293-19424-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:35176 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751135AbbEGMVg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 May 2015 08:21:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to igb only.

Toshiaki provides two fixes for igb, first fixes an issue when changing
the number of rings by ethtool which causes oops because of uninitialized
pointers.  The second fix resolves a typo where tx_ring was used instead
of the desired rx_ring.

The following are changes since commit 31ccd0e66d41f73cfc21a8de976e713455205228:
  tcp_westwood: fix tcp_westwood_info()
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-queue master

Toshiaki Makita (2):
  igb: Fix oops on changing number of rings
  igb: Fix NULL assignment to incorrect variable in igb_reset_q_vector

 drivers/net/ethernet/intel/igb/igb_main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

-- 
2.1.0
