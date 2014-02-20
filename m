From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 0/3] Intel Wired LAN Driver Updates
Date: Wed, 19 Feb 2014 20:45:18 -0800
Message-ID: <1392871521-7731-1-git-send-email-aaron.f.brown@intel.com>
Cc: Aaron Brown <aaron.f.brown@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:30889 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752935AbaBTEsL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Feb 2014 23:48:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe for LER / adapter removal.
Mark restores the HW address in the recovery path so the device is
not perpetually removed, fixes up some removed state ethtool results
and adds checks related to config space access.


Mark Rustad (3):
  ixgbe: Restore hw_addr in LER recovery paths
  ixgbe: Fix up some ethtool results when adapter is removed
  ixgbe: Check config reads for removal

 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c   | 10 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c  | 16 +++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h  |  6 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |  9 +++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 62 +++++++++++++++++++++---
 5 files changed, 85 insertions(+), 18 deletions(-)

-- 
1.8.5.GIT
