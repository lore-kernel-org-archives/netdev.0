From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/11][pull request] Intel Wired LAN Driver Updates
Date: Fri, 24 Feb 2012 21:49:49 -0800
Message-ID: <1330149000-25907-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:2449 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750911Ab2BYFuD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Feb 2012 00:50:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches contains cleanups of the e1000e driver.

The following are changes since commit 5d74f1757001f5b9a7739c2a9053435e16ce516b:
  Staging: wlags49_h2: print MAC via printk format specifier
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Bruce Allan (11):
  e1000e: cleanup: rename e1000e_id_led_init() and call as function
    pointer
  e1000e: cleanup: rename e1000e_setup_link() and call as function
    pointer
  e1000e: cleanup use of check_mng_mode function pointer
  e1000e: cleanup use of check_reset_block function pointer
  e1000e: cleanup calls to setup_physical_interface function pointer
  e1000e: comment correction in
    e1000e_set_kmrn_lock_loss_workaround_ich8lan
  e1000e: rename e1000e_config_collision_dist() and call as function
    pointer
  e1000e: cleanup comment in e1000_hash_mc_addr()
  e1000e: use true/false for boolean send_xon, do not assume always
    true
  e1000e: cleanup - remove unnecessary variable
  e1000e: rename e1000e_reload_nvm() and call as function pointer

 drivers/net/ethernet/intel/e1000e/80003es2lan.c |   12 +++++---
 drivers/net/ethernet/intel/e1000e/82571.c       |   10 ++++---
 drivers/net/ethernet/intel/e1000e/e1000.h       |   18 +++----------
 drivers/net/ethernet/intel/e1000e/ethtool.c     |    6 +++-
 drivers/net/ethernet/intel/e1000e/hw.h          |    2 +
 drivers/net/ethernet/intel/e1000e/ich8lan.c     |   32 ++++++++++++----------
 drivers/net/ethernet/intel/e1000e/mac.c         |   31 ++++++++++-----------
 drivers/net/ethernet/intel/e1000e/manage.c      |    4 +-
 drivers/net/ethernet/intel/e1000e/netdev.c      |    8 +++---
 drivers/net/ethernet/intel/e1000e/nvm.c         |    4 +-
 drivers/net/ethernet/intel/e1000e/phy.c         |    6 ++--
 11 files changed, 66 insertions(+), 67 deletions(-)

-- 
1.7.7.6
