From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/4 v2][pull request] Intel Wired LAN Driver Updates
Date: Thu, 20 Sep 2012 03:07:13 -0700
Message-ID: <1348135637-17857-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:17508 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753304Ab2ITKHT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2012 06:07:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to igb and ixgbevf.

v2: updated patch description in 04 patch (ixgbevf: scheduling while
    atomic in reset hw path)

The following are changes since commit aee77e4accbeb2c86b1d294cd84fec4a12dde3bd:
  r8169: use unlimited DMA burst for TX
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Akeem G. Abodunrin (1):
  igb: Support to enable EEE on all eee_supported devices

Alexander Duyck (2):
  igb: Remove artificial restriction on RQDPC stat reading
  ixgbevf: Add support for VF API negotiation

John Fastabend (1):
  ixgbevf: scheduling while atomic in reset hw path

 drivers/net/ethernet/intel/igb/e1000_82575.c      | 17 +++++++---
 drivers/net/ethernet/intel/igb/e1000_defines.h    |  3 +-
 drivers/net/ethernet/intel/igb/e1000_regs.h       |  1 +
 drivers/net/ethernet/intel/igb/igb_main.c         |  8 +++--
 drivers/net/ethernet/intel/ixgbevf/defines.h      |  1 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 23 +++++++++++++
 drivers/net/ethernet/intel/ixgbevf/mbx.h          | 21 ++++++++++--
 drivers/net/ethernet/intel/ixgbevf/vf.c           | 39 ++++++++++++++++++++++-
 drivers/net/ethernet/intel/ixgbevf/vf.h           |  3 ++
 9 files changed, 105 insertions(+), 11 deletions(-)

-- 
1.7.11.4
