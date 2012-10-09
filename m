From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/3][pull request] Intel Wired LAN Driver Updates
Date: Tue,  9 Oct 2012 03:13:29 -0700
Message-ID: <1349777612-30149-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:57651 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751089Ab2JIKNj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2012 06:13:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe, ixgbevf and e1000e.

The following are changes since commit 66eef59f22275002f621ff9d951886b513d011b3:
  net: fix typo in freescale/ucc_geth.c
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Alexander Duyck (1):
  ixgbe/ixgbevf: Limit maximum jumbo frame size to 9.5K to avoid Tx
    hangs

Bruce Allan (1):
  e1000e: add device IDs for i218

Greg Rose (1):
  ixgbevf: Set the netdev number of Tx queues

 drivers/net/ethernet/intel/e1000e/hw.h            | 2 ++
 drivers/net/ethernet/intel/e1000e/netdev.c        | 2 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe.h          | 2 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      | 2 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 7 +++++++
 5 files changed, 13 insertions(+), 2 deletions(-)

-- 
1.7.11.4
