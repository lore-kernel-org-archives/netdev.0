From: Yi Zou <yi.zou@intel.com>
Subject: [PATCH 0/3] net: New flags for Fibre Channel over Ethernet (FCoE)
	(Resubmit)
Date: Mon, 17 Nov 2008 10:38:25 -0800
Message-ID: <20081117183539.15856.46809.stgit@zychongqing.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:56408 "EHLO mga02.intel.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750922AbYKQSs6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 13:48:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
Appologize if you have received multiple copy of this, failed to send to
netdev mailing list in the first attemp. 

Anyway, tese are the patches adding flags for Fiber Channel over Ethernet 
(FCoE) that have been updated to the current tip of net-next.git. The original
submission can be found by the following thread: 
http://marc.info/?l=linux-netdev&m=122228979113312&w=2

Please consider inclusion for these flags.

Many thanks.

yi

---

Chris Leech (2):
      net: define feature flags for FCoE offloads
      net: reclaim 8 upper bits of the netdev->features from GSO

Yi Zou (1):
      net: add ETH_P_FCOE for Fibre Channel over Ethernet (FCoE)


 drivers/net/xen-netfront.c |    2 +-
 include/linux/if_ether.h   |    1 +
 include/linux/netdevice.h  |    5 ++++-
 include/linux/skbuff.h     |    2 ++
 4 files changed, 8 insertions(+), 2 deletions(-)

-- 
Signature: Yi Zou <yi.zou@intel.com>

