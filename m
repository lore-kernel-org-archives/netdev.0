From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/8][pull request] Intel Wired LAN Driver Updates
Date: Tue, 23 Oct 2012 03:24:39 -0700
Message-ID: <1350987887-16161-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:54686 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752560Ab2JWKYv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2012 06:24:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000e, igb, ixgbevf and MAINTAINERS.

The following are changes since commit 598e74f32c6dd4b3dd0ed382c889be07a7c6cbc0:
  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Carolyn Wyborny (2):
  igb: Update get cable length function for i210/i211
  igb: Update version

Greg Rose (2):
  ixgbevf: Check for error on dma_map_single call
  ixgbevf: Update version string

Jesse Brandeburg (1):
  maintainers: update with official intel support link, new maintainer

John Fastabend (2):
  ixgbevf: make netif_napi_add and netif_napi_del symmetric
  ixgbevf: fix softirq-safe to unsafe splat on internal mbx_lock

Tushar Dave (1):
  e1000e: Minimum packet size must be 17 bytes

 MAINTAINERS                                       |  2 +
 drivers/net/ethernet/intel/e1000e/netdev.c        | 11 +++++
 drivers/net/ethernet/intel/igb/e1000_phy.c        | 20 ++++++++
 drivers/net/ethernet/intel/igb/igb_main.c         |  2 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 59 ++++++++++++-----------
 5 files changed, 64 insertions(+), 30 deletions(-)

-- 
1.7.11.7
