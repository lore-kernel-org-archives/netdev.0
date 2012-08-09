From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: [net 0/3][pull request] Intel Wired LAN Driver Updates
Date: Thu,  9 Aug 2012 02:39:09 -0700
Message-ID: <1344505152-28167-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Cc: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:6239 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751495Ab2HIJjV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2012 05:39:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains bugfixes to the igb and e1000e drivers.

The following are changes since commit 36471012e2ae28ca3178f84d4687a2d88a36593e:
  
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/ppwaskie/net master

Alexander Duyck (1):
  igb: Fix register defines for all non-82575 hardware

Emil Tantilov (2):
  igb: fix panic while dumping packets on Tx hang with IOMMU
  e1000e: fix panic while dumping packets on Tx hang with IOMMU

 drivers/net/ethernet/intel/e1000e/netdev.c  | 36 +++++++++++++++++++++--------
 drivers/net/ethernet/intel/igb/e1000_regs.h |  8 +++++--
 drivers/net/ethernet/intel/igb/igb_main.c   | 19 ++++++++-------
 3 files changed, 41 insertions(+), 22 deletions(-)

-- 
1.7.11.2
