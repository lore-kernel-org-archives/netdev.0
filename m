From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/2][pull request] Intel Wired LAN Driver Update
Date: Sat,  2 Jun 2012 00:16:54 -0700
Message-ID: <1338621416-22425-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:20916 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966240Ab2FBHRA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Jun 2012 03:17:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains fixes for e1000 and e1000e.

The following are changes since commit ad1be8d345416a794dea39761a374032aa471a76:
  r8169: call netif_napi_del at errpaths and at driver unload
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Bruce Allan (1):
  e1000e: fix Rapid Start Technology support for i217

Sebastian Andrzej Siewior (1):
  e1000: look into the page instead of skb->data for
    e1000_tbi_adjust_stats()

 drivers/net/ethernet/intel/e1000/e1000_main.c |    2 +-
 drivers/net/ethernet/intel/e1000e/ich8lan.c   |   18 +++++++++---------
 2 files changed, 10 insertions(+), 10 deletions(-)

-- 
1.7.10.2
