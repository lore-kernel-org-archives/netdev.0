From: Kiran Patil <kiran.patil@intel.com>
Subject: [RFC PATCH 0/2] Preparing NetDev and VLAN for FCoE targets (offload
	using DDP)
Date: Wed, 26 Jan 2011 10:08:55 -0800
Message-ID: <20110126180855.25039.82793.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	yi.zou@intel.com, robert.w.love@intel.com, kiran.patil@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:50746 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753944Ab1AZSGz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jan 2011 13:06:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series implements...

1) NetDev: Add ndo_fcoe_ddp_target() in struct net_device_ops to 
   support FCoE DDP in target mode
2) VLAN: Add new target DDP offload support ndo_fcoe_ddp_target.
   This patch depends upon patch 1 of this series. 


Dependencies: This series is preparing the NetDev and VLAN for
   FCoE target (offload using DDP). This series is pre-requistie 
   for the patch which shall be submitted later after final version
   of these patches for ixgbe (10Gb Ethernet Driver).

---

Yi Zou (2):
      vlan: add support to ndo_fcoe_ddp_target()
      net: add ndo_fcoe_ddp_target() to support FCoE DDP in target mode


 drivers/net/ixgbe/ixgbe.h      |    2 +
 drivers/net/ixgbe/ixgbe_fcoe.c |   86 ++++++++++++++++++++++++++++++++++------
 drivers/net/ixgbe/ixgbe_fcoe.h |    4 ++
 drivers/net/ixgbe/ixgbe_main.c |    1 
 include/linux/netdevice.h      |    4 ++
 net/8021q/vlan_dev.c           |   14 +++++++
 6 files changed, 99 insertions(+), 12 deletions(-)

-- 
Thanks,
-- Kiran P
