From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 0/3] Intel Wired LAN Driver Updates
Date: Fri, 17 Jan 2014 01:21:35 -0800
Message-ID: <1389950498-8820-1-git-send-email-aaron.f.brown@intel.com>
Cc: Aaron Brown <aaron.f.brown@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:64977 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750937AbaAQJVp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jan 2014 04:21:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains an updates to ixgbe and ixgbevf.

Jacob add braces around some ixgbe_qv_lock_* calls lto better adhere 
to Kernel style guidelines.  Don bumps the versions on ixgbe and
ixgbevf to match internal driver functionality better.

Don Skidmore (2):
  ixgbe: bump version number
  ixgbevf: bump version

Jacob Keller (1):
  ixgbe: add braces around else condition in ixgbe_qv_lock_* calls

 drivers/net/ethernet/intel/ixgbe/ixgbe.h          | 6 ++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     | 2 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 2 +-
 3 files changed, 6 insertions(+), 4 deletions(-)

-- 
1.8.5.GIT
