From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net v2 0/6][pull request] Intel Wired LAN Driver Updates
Date: Fri, 27 Sep 2013 05:35:52 -0700
Message-ID: <1380285358-15685-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:20970 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751185Ab3I0MgC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Sep 2013 08:36:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to igb and i40e.

Todd provides a fix for 82580 devices in igb, where the ethtool
loopback test was missing 82580 copper devices.

Jesse provides five fixes/cleanups to i40e based on feedback from
Joe Perches and the community.

v2: fixed up patch 5 in the series based on feedback from Joe Perches
    and David Miller

The following are changes since commit f875691640cd3fa67f7ad1d3130ff9fa7fdca042:
  Merge branch 'fixes-for-3.12' of git://gitorious.org/linux-can/linux-can
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Jesse Brandeburg (5):
  i40e: use common failure flow
  i40e: small clean ups from review
  i40e: convert ret to aq_ret
  i40e: better return values
  i40e: clean up coccicheck reported errors

Todd Fujinaka (1):
  igb: Fix ethtool loopback test for 82580 copper

 drivers/net/ethernet/intel/i40e/i40e_adminq.c |   7 +-
 drivers/net/ethernet/intel/i40e/i40e_common.c |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c   | 162 +++++++++++++-------------
 drivers/net/ethernet/intel/igb/igb_ethtool.c  |   3 +
 4 files changed, 89 insertions(+), 85 deletions(-)

-- 
1.8.3.1
