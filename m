From: Yi Zou <yi.zou@intel.com>
Subject: [PATCH 0/3] New flags for Fibre Channel over Ethernet (FCoE) (v2)
Date: Mon, 06 Oct 2008 16:39:13 -0700
Message-ID: <20081006233409.4918.82298.stgit@zyfc9ini.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:61711 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751761AbYJFXlq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Oct 2008 19:41:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2 of the patches to add flags for Fibre Channel over Ethernet (FCoE) at
Open-FCoE.org. Apologize for the incomplete series sent earlier. Also fixed
the style issue in the first patch.

The first patch adds the protocol type as ETH_P_FCOE for FCoE protocol. The
second one claims 8 bits back from NETIF_F_GSO_MASK to host NETIF_F_FCOE_CRC,
and the third one adds NETIF_F_FCOE_CRC, NETIF_F_GSO_FCOE, and SKB_GSO_FCOE.
Feature flags regarding offload features for FCoE are based on the earlier
post at http://marc.info/?l=linux-netdev&m=122228979113312&w=2.

thanks.

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
Signature : Yi Zou <yi.zou@intel.com>
