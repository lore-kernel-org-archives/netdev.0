From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/2][pull request] Intel Wired LAN Driver Updates
Date: Wed, 16 Jan 2013 01:03:47 -0800
Message-ID: <1358327029-13340-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:57242 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932292Ab3APJDx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2013 04:03:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe only.

The following are changes since commit daf3ec688e057f6060fb9bb0819feac7a8bbf45c:
  tg3: Fix crc errors on jumbo frame receive
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Jacob Keller (2):
  ixgbe: only compile ixgbe_debugfs.o when enabled
  ixgbe: Fix overwriting of rx_mtrl in ixgbe_ptp_hwtstamp_ioctl

 drivers/net/ethernet/intel/ixgbe/Makefile        | 3 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c | 5 -----
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c     | 4 ++--
 3 files changed, 4 insertions(+), 8 deletions(-)

-- 
1.7.11.7
