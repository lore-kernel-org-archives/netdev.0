From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/3][pull request] Intel Wired LAN Driver Updates
Date: Thu,  7 Mar 2013 03:15:22 -0800
Message-ID: <1362654925-26088-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, bruce.w.allan@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:5166 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756243Ab3CGLPi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Mar 2013 06:15:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000e only.

All three patches come from Konstantin Khlebnikov to resolve power
management issues.  The first patch removes redundant and unbalanced
pci_disable_device() from the shutdown function.  The second patch
removes redundant actions from the driver and fixes the interaction
with actions in pci-bus runtime power management code.  The third
and last patch fixes some messages like 'Error reading PHY register'
and 'Hardware Erorr' and saves several seconds on reboot.

The following are changes since commit f8af75f3517a24838a36eb5797a1a3e60bf9e276:
  tun: add a missing nf_reset() in tun_net_xmit()
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Konstantin Khlebnikov (3):
  e1000e: fix pci-device enable-counter balance
  e1000e: fix runtime power management transitions
  e1000e: fix accessing to suspended device

 drivers/net/ethernet/intel/e1000e/ethtool.c | 13 +++++
 drivers/net/ethernet/intel/e1000e/netdev.c  | 82 ++++++++---------------------
 2 files changed, 34 insertions(+), 61 deletions(-)

-- 
1.7.11.7
