From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/2][pull request] Intel Wired LAN Driver Updates 2017-10-10
Date: Tue, 10 Oct 2017 08:14:14 -0700
Message-ID: <20171010151416.43149-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:50722 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932296AbdJJPOg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 10 Oct 2017 11:14:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e only.

Stefano Brivio fixes the grammar in a function header comment.

Alex fixes a memory leak where we were not correctly placing the pages
from buffers that had been used to return a filter programming status
back on the ring.

The following are changes since commit 529a86e063e9ff625c4ff247d8aa17d8072444fb:
  Merge branch 'ppc-bundle' (bundle from Michael Ellerman)
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-queue 40GbE

Alexander Duyck (1):
  i40e: Fix memory leak related filter programming status

Stefano Brivio (1):
  i40e: Fix comment about locking for __i40e_read_nvm_word()

 drivers/net/ethernet/intel/i40e/i40e_nvm.c  |  2 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 63 ++++++++++++++++-------------
 2 files changed, 37 insertions(+), 28 deletions(-)

-- 
2.14.2
