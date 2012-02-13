From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] Intel Wired LAN Driver updates
Date: Mon, 13 Feb 2012 13:47:35 -0800
Message-ID: <1329169670-5403-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:3407 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754273Ab2BMVry (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 16:47:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to e1000e only.  All of the
patches are cleanup of the e1000e driver.

The following are changes since commit fafdbf84d7eb2cd7aee435cc381a0796e1a5ccb0:
  trivial: typo hnalder -> handler
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Bruce Allan (15):
  e1000e: cleanup: use goto for common work needed by multiple exit
    points
  e1000e: cleanup: rename goto labels to be more meaningful
  e1000e: potentially incorrect return for
    e1000_cfg_kmrn_10_100_80003es2lan
  e1000e: potential incorrect return for
    e1000_setup_copper_link_80003es2lan
  e1000e: cleanup: remove unnecessary assignments just before returning
  e1000e: cleanup: always return 0
  e1000e: potentially incorrect return for
    e1000_set_d3_lplu_state_ich8lan
  e1000e: cleanup: remove unreachable statement
  e1000e: cleanup: remove unnecessary variable ret_val
  e1000e: cleanup: remove unnecessary test and return
  e1000e: cleanup: remove unnecessary variable initializations
  e1000e: cleanup: minor whitespace addition (insert blank line
    separator)
  e1000e: potentially incorrect return for e1000_init_hw_ich8lan
  e1000e: potentially incorrect return for
    e1000e_setup_fiber_serdes_link
  e1000e: cleanup goto statements to exit points without common work

 drivers/net/ethernet/intel/e1000e/80003es2lan.c |   36 +---
 drivers/net/ethernet/intel/e1000e/82571.c       |   36 ++---
 drivers/net/ethernet/intel/e1000e/ich8lan.c     |  220 +++++++++------------
 drivers/net/ethernet/intel/e1000e/mac.c         |   25 +--
 drivers/net/ethernet/intel/e1000e/manage.c      |   32 +--
 drivers/net/ethernet/intel/e1000e/netdev.c      |   16 +-
 drivers/net/ethernet/intel/e1000e/nvm.c         |   32 ++--
 drivers/net/ethernet/intel/e1000e/phy.c         |  241 ++++++++++-------------
 8 files changed, 265 insertions(+), 373 deletions(-)

-- 
1.7.7.6
