From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/5][pull request] Intel Wired LAN Driver Updates
Date: Fri, 21 Oct 2011 03:31:56 -0700
Message-ID: <1319193121-2729-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:30637 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754133Ab1JUKcF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Oct 2011 06:32:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to igbvf and igb.
This version of the series contains the following changes:

- igb 2 fixes (VFTA table, Alt. MAC addr) and move DMA coalescing init
  code into separate function
- igbvf bump version and update identification strings

The following are changes since commit :
  
and are available in the git repository at
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next.git

Carolyn Wyborny (3):
  igb: Fix for Alt MAC Address feature on 82580 and later devices
  igb: Move DMA Coalescing init code to separate function.
  igb: VFTA Table Fix for i350 devices

Williams, Mitch A (2):
  igbvf: Update module identification strings
  igbvf: Bump version number

 drivers/net/ethernet/intel/igb/e1000_82575.c |    5 +-
 drivers/net/ethernet/intel/igb/e1000_mac.c   |   63 ++++++++++++-
 drivers/net/ethernet/intel/igb/e1000_mac.h   |    1 +
 drivers/net/ethernet/intel/igb/igb.h         |    1 +
 drivers/net/ethernet/intel/igb/igb_main.c    |  130 +++++++++++++++-----------
 drivers/net/ethernet/intel/igbvf/netdev.c    |   14 ++-
 6 files changed, 148 insertions(+), 66 deletions(-)

-- 
1.7.6.4
