From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [Patch v6 net-next 0/2] Intel Wired LAN Driver Updates
Date: Thu, 16 Jan 2014 19:41:03 -0800
Message-ID: <1389930065-3330-1-git-send-email-aaron.f.brown@intel.com>
Cc: Aaron Brown <aaron.f.brown@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, ethan.kernel@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:30935 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751357AbaAQDlL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jan 2014 22:41:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe Ethan Zhao.  The first one replaces
the magic number "63" with a macro, IXGBE_MAX_VFS_DRV_LIMIT, the second 
moves the call to set driver_max_VFS to before SRIOV is enabled.

The code of these patches match the v3 (1/2) and v2 (2/2) versions sent
to the e1000-devel and netdev mailing lists.  The intermediate versions
(v4, v5) are from sorting out style issues, mostly tabs to spaces and
split lines probably introduced via mailer.

ethan.zhao (2):
  1/2 ixgbe: define IXGBE_MAX_VFS_DRV_LIMIT macro and cleanup const 63
  2/2 ixgbe: set driver_max_VFs should be done before enabling SRIOV  

 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  | 4 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 4 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h | 5 +++++
 3 files changed, 9 insertions(+), 4 deletions(-)

-- 
1.8.5.GIT
