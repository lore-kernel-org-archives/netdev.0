From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/4][pull request] Intel Wired LAN Driver Updates
Date: Tue, 18 Sep 2012 21:31:44 -0700
Message-ID: <1348029108-26659-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:50405 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752856Ab2ISEb6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2012 00:31:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to igb and ixgbevf.

The following are changes since commit adccff34de1ef81564b7e6c436f762e7a1caf807:
  net/tipc/name_table.c: Remove unecessary semicolon
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
