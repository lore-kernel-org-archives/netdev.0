From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/3][pull request] Intel Wired LAN Driver Updates 2014-12-31
Date: Wed, 31 Dec 2014 16:04:12 -0800
Message-ID: <1420070655-28453-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:8966 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751685AbbAAAES (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Dec 2014 19:04:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to fixes for e100, igb and i40e.

John Linville fixes a typo in e100 that has been around for some time,
where an attempted revert actually inverted the test for eeprom_mdix_enabled.

Todd fixes up a code comment that should have been removed back in 2007.

Joe Perches fixes a possible memory leak in i40e which was reported by
Dan Carpenter using smatch.

The following are changes since commit 2c90331cf5ed1d648a711b9483e173aaaf2c4a9b:
  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Joe Perches (1):
  i40e: Fix possible memory leak in i40e_dbg_dump_desc

John W. Linville (1):
  e100: fix typo in MDI/MDI-X eeprom check in e100_phy_init

Todd Fujinaka (1):
  igb: Remove unneeded FIXME

 drivers/net/ethernet/intel/e100.c              | 2 +-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 4 +++-
 drivers/net/ethernet/intel/igb/e1000_82575.c   | 2 +-
 3 files changed, 5 insertions(+), 3 deletions(-)

-- 
1.9.3
