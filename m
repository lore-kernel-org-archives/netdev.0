From: Stefano Brivio <sbrivio@redhat.com>
Subject: [PATCH net 0/2] i40e: Two trivial fixes for 09f79fd49d94
Date: Wed,  6 Sep 2017 10:11:37 +0200
Message-ID: <cover.1504684488.git.sbrivio@redhat.com>
Cc: "David S . Miller" <davem@davemloft.net>,
        Anjali Singhai Jain <anjali.singhai@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46774 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750832AbdIFIMD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 6 Sep 2017 04:12:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two trivial fixes for recently introduced 09f79fd49d94 ("i40e: avoid NVM
acquire deadlock during NVM update"): 1/2 fixes a comment about locking
and 2/2 gets rid of two useless variables and one initializer in nvm
functions.

Stefano Brivio (2):
  i40e: Fix comment about locking for __i40e_read_nvm_word()
  i40e: Avoid some useless variables and initializers in nvm functions

 drivers/net/ethernet/intel/i40e/i40e_nvm.c | 22 ++++++++--------------
 1 file changed, 8 insertions(+), 14 deletions(-)

-- 
2.9.4
