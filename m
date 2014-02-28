From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next v2 0/4]
Date: Fri, 28 Feb 2014 15:48:54 -0800
Message-ID: <1393631338-18847-1-git-send-email-aaron.f.brown@intel.com>
Cc: Aaron Brown <aaron.f.brown@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:11497 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751723AbaB1XwZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Feb 2014 18:52:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mark updates ixgbe for LER / adapter removal.  He restores the HW
address in the recovery path so the device is not perpetually removed,
fixes up some removed state ethtool results and adds checks related to
config space access.

Jacob adds support for the new SIOCGHWTSTAMP ioctl.

Mark Rustad (3):
  ixgbe: Restore hw_addr in LER recovery paths
  ixgbe: Fix up some ethtool results when adapter is removed
  ixgbe: Check config reads for removal

Jacob Keller (1):
  ixgbe: implement SIOCGHWTSTAMP ioctl

 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |  5 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c   | 10 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c  | 16 +++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h  |  6 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |  9 +++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 68 +++++++++++++++++++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c     | 23 ++++++--
 7 files changed, 111 insertions(+), 26 deletions(-)

-- 
1.8.5.GIT
