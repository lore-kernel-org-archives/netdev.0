From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/7][pull request] Intel Wired LAN Driver Updates
Date: Sat, 22 Sep 2012 03:30:29 -0700
Message-ID: <1348309836-7107-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:39138 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751809Ab2IVKan (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Sep 2012 06:30:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to igb only.

The following are changes since commit abb17e6c0c7b27693201dc85f75dbb184279fd10:
  netlink: use <linux/export.h> instead of <linux/module.h>
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (5):
  igb: Remove logic that was doing NUMA pseudo-aware allocations
  igb: Change Tx cleanup loop to do/while instead of for
  igb: Change how we populate the RSS indirection table
  igb: Simplify how we populate the RSS key
  igb: Use dma_unmap_addr and dma_unmap_len defines

Carolyn Wyborny (1):
  igb: Fix stats output on i210/i211 parts.

Stefan Assmann (1):
  igb: Change how we check for pre-existing and assigned VFs

 drivers/net/ethernet/intel/igb/igb.h      |   8 +-
 drivers/net/ethernet/intel/igb/igb_main.c | 370 ++++++++++--------------------
 2 files changed, 122 insertions(+), 256 deletions(-)

-- 
1.7.11.4
