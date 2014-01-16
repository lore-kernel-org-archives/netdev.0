From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 0/2] Intel Wired LAN Driver Updates
Date: Wed, 15 Jan 2014 17:38:39 -0800
Message-ID: <1389836321-17013-1-git-send-email-aaron.f.brown@intel.com>
Cc: Aaron Brown <aaron.f.brown@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:31147 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751379AbaAPBij (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jan 2014 20:38:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains several updates from Alex to ixgbe.

To avoid head of line blocking in the event a VF stops cleaning Rx descriptors
he makes sure QDE bits are set for a VF before the Rx queues are enabled.

To avoid a situation where the head write-back registers can remain set ofter 
the driver is unloaded he clears them on a VF reset.

Alexander Duyck (2):
  ixgbe: Force QDE via PFQDE for VFs during reset
  ixgbe: Clear head write-back registers on VF reset

 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 23 +++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h  | 15 ++++++++++++---
 2 files changed, 35 insertions(+), 3 deletions(-)

-- 
1.8.5.GIT
