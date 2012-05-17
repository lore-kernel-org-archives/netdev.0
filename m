From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/4][pull request] Intel Wired LAN Driver Updates
Date: Thu, 17 May 2012 04:27:46 -0700
Message-ID: <1337254070-32500-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:48755 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761630Ab2EQL1y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2012 07:27:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches contains updates for e1000, e1000e and igb.

The following are changes since commit dc6b9b78234fecdc6d2ca5e1629185718202bcf5:
  net: include/net/sock.h cleanup
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Bruce Allan (1):
  e1000e: fix typo in definition of E1000_CTRL_EXT_FORCE_SMBUS

Matthew Vick (1):
  igb: Disable the BMC-to-OS Watchdog Enable bit for DMAC.

Sebastian Andrzej Siewior (2):
  e1000: remove workaround for Errata 23 from jumbo alloc
  e1000: look in the page and not in skb->data for the last byte

 drivers/net/ethernet/intel/e1000/e1000_main.c  |   30 ++++--------------------
 drivers/net/ethernet/intel/e1000e/defines.h    |    2 +-
 drivers/net/ethernet/intel/igb/e1000_defines.h |    2 +
 drivers/net/ethernet/intel/igb/igb_main.c      |    3 ++
 4 files changed, 11 insertions(+), 26 deletions(-)

-- 
1.7.7.6
