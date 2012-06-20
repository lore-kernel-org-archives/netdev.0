From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/3][pull request] Intel Wired LAN Driver Updates
Date: Wed, 20 Jun 2012 01:44:39 -0700
Message-ID: <1340181882-16333-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:38315 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753365Ab2FTIoo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2012 04:44:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains fixes to igb, ixgbe and intel/Kconfig

The following are changes since commit 2c995ff892313009e336ecc8ec3411022f5b1c39:
  batman-adv: fix skb->data assignment
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Alexander Duyck (1):
  ixgbe: Fix memory leak in ixgbe when receiving traffic on DDP enabled
    rings

Carolyn Wyborny (2):
  igb: Fix incorrect RAR address entries for i210/i211 device.
  Kconfig: Fix Kconfig for Intel ixgbe and igb PTP support.

 drivers/net/ethernet/intel/Kconfig            |   10 +++++++---
 drivers/net/ethernet/intel/igb/e1000_82575.c  |    2 --
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    2 +-
 3 files changed, 8 insertions(+), 6 deletions(-)

-- 
1.7.10.2
