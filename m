From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-nexti v2 00/15][pull request] Intel Wired LAN Driver Updates
Date: Wed, 16 Jan 2013 01:10:12 -0800
Message-ID: <1358327427-3146-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:36112 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932403Ab3APJKa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2013 04:10:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000e only.

v2- updates patch 09/15 "e1000e: resolve checkpatch PREFER_PR_LEVEL warning"
    based on feedback from Joe Perches.

The following are changes since commit 247fa82be1301e4f89eaa5dc10be62a9cc84e8c5:
  bnx2x: Introduce 2013 and advance version to 1.78.02
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Bruce Allan (15):
  e1000e: SerDes autoneg flow control
  e1000e: Acquire/release semaphore when writing each EEPROM page
  e1000e: Invalid Image CSUM bit changed for I217
  e1000e: helper functions for accessing EMI registers
  e1000e: 82577: workaround for link drop issue
  e1000e: fix enabling of EEE on 82579 and I217
  e1000e: unexpected "Reset adapter" message when cable pulled
  e1000e: add missing bailout on error
  e1000e: resolve checkpatch PREFER_PR_LEVEL warning
  e1000e: cleanup redundant statistics counter
  e1000e: cleanup unusual comment placement
  e1000e: cleanup unnecessary line wrap
  e1000e: cleanup magic number
  e1000e: cleanup code duplication
  e1000e: merge multiple conditional statements into one

 drivers/net/ethernet/intel/e1000e/defines.h |  10 +-
 drivers/net/ethernet/intel/e1000e/e1000.h   |   2 +-
 drivers/net/ethernet/intel/e1000e/ethtool.c |   1 -
 drivers/net/ethernet/intel/e1000e/hw.h      |   4 +
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 213 +++++++++++++++++++++-------
 drivers/net/ethernet/intel/e1000e/mac.c     | 125 ++++++++++++++++
 drivers/net/ethernet/intel/e1000e/netdev.c  |  66 ++++-----
 drivers/net/ethernet/intel/e1000e/nvm.c     |  26 ++--
 drivers/net/ethernet/intel/e1000e/param.c   |   3 +-
 9 files changed, 339 insertions(+), 111 deletions(-)

-- 
1.7.11.7
