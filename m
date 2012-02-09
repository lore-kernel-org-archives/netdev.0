From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/7][pull request] Intel Wired LAN Driver Updates
Date: Thu,  9 Feb 2012 02:27:55 -0800
Message-ID: <1328783282-17760-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:60039 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757851Ab2BIK2M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Feb 2012 05:28:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to igb and e1000e.
Majority of the updates are to e1000e and do the following:
 - several cleanups which remove unnecessary () and returns from void
   functions
 - remove test that is always false
 - use 'true' instead of '1' for boolean
The one igb fix resolves warning about unused function.

The following are changes since commit a584b7ae4ef01425f6827657abdc3e4db49b3578:
  netxen_nic: signedness bug in netxen_md_entry_err_chk()
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Bruce Allan (6):
  e1000e: remove test that is always false
  e1000e: remove unnecessary returns from void functions
  e1000e: remove unnecessary parentheses
  e1000e: use true/false for bool autoneg_false
  e1000e: pass pointer to hw struct for e1000_init_mac_params_XXX()
  e1000e: replace '1' with 'true' for boolean get_link_status

Emil Tantilov (1):
  igb: fix warning about unused function

 drivers/net/ethernet/intel/e1000e/80003es2lan.c |    7 ++---
 drivers/net/ethernet/intel/e1000e/82571.c       |    9 +++---
 drivers/net/ethernet/intel/e1000e/ethtool.c     |    4 +-
 drivers/net/ethernet/intel/e1000e/ich8lan.c     |    8 +----
 drivers/net/ethernet/intel/e1000e/mac.c         |   32 ++++++++++-------------
 drivers/net/ethernet/intel/e1000e/manage.c      |    2 +-
 drivers/net/ethernet/intel/e1000e/netdev.c      |   13 +++-----
 drivers/net/ethernet/intel/e1000e/phy.c         |   12 ++++----
 drivers/net/ethernet/intel/igb/igb_main.c       |    4 +++
 9 files changed, 41 insertions(+), 50 deletions(-)

-- 
1.7.7.6
