From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/2][pull request] Intel Wired LAN Driver Updates 2016-01-25
Date: Mon, 25 Jan 2016 15:58:50 -0800
Message-ID: <1453766332-43274-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:32347 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751275AbcAYX7N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jan 2016 18:59:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e only and so I won't continue receiving
patches to fix the same issue (again).

Arnd fixes the driver from causing the compiler whining about uninitialized
variables, so initialize those variables.

Eric fixes the build errors/warnings which were introduced by Anjali
when she added geneve support to i40e.


The following are changes since commit c85e4924452ae8225c8829f3fa8a2f7baa34bc5c:
  hv_netvsc: Fix book keeping of skb during batching process
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-queue master

Arnd Bergmann (1):
  net: i40e: shut up uninitialized variable warnings

Eric Dumazet (1):
  i40e: fix build warnings

 drivers/net/ethernet/intel/i40e/i40e_main.c | 15 +++++----------
 drivers/net/ethernet/intel/i40e/i40e_txrx.c |  4 ++--
 2 files changed, 7 insertions(+), 12 deletions(-)

-- 
2.5.0
