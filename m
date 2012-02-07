From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/11][pull request] Intel Wired LAN Driver Updates
Date: Tue,  7 Feb 2012 04:33:47 -0800
Message-ID: <1328618038-5008-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:47275 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755676Ab2BGMeL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Feb 2012 07:34:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to e1000, igbvf and e1000e.
Majority of the updates are to e1000e and do the following:
 - cleanup 82571 and 80003es2lan code
 - fix checkpatch and sparse warnings
 - fix whitespace/indentation
 - add missing initializers

The following are changes since commit 59d74026fa4b5df72a268f1e9578af500154ad07:
  Merge branch 'for-davem' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Bruce Allan (9):
  e1000e: add missing initializers reported when compiling with W=1
  e1000e: cleanup - check return values consistently
  e1000e: cleanup e1000_init_mac_params_80003es2lan()
  e1000e: cleanup e1000_init_mac_params_82571()
  e1000e: cleanup e1000_set_phys_id
  e1000e: cleanup - use braces in both branches of a conditional
    statement
  e1000e: fix checkpatch warning from MINMAX test
  e1000e: fix sparse warnings with -D__CHECK_ENDIAN__
  e1000e: minor whitespace and indentation cleanup

Mitch A Williams (1):
  igbvf: refactor Interrupt Throttle Rate code

Tushar Dave (1):
  e1000: Adding e1000_dump function

 drivers/net/ethernet/intel/e1000/e1000.h        |    1 +
 drivers/net/ethernet/intel/e1000/e1000_hw.h     |   10 +
 drivers/net/ethernet/intel/e1000/e1000_main.c   |  224 +++++++++++++++++++++++
 drivers/net/ethernet/intel/e1000e/80003es2lan.c |   28 +--
 drivers/net/ethernet/intel/e1000e/82571.c       |   72 +++-----
 drivers/net/ethernet/intel/e1000e/ethtool.c     |    8 +-
 drivers/net/ethernet/intel/e1000e/ich8lan.c     |   12 +-
 drivers/net/ethernet/intel/e1000e/netdev.c      |  104 ++++++-----
 drivers/net/ethernet/intel/igbvf/ethtool.c      |   19 +-
 drivers/net/ethernet/intel/igbvf/igbvf.h        |   27 ++--
 drivers/net/ethernet/intel/igbvf/netdev.c       |  131 ++++++++------
 11 files changed, 438 insertions(+), 198 deletions(-)

-- 
1.7.7.6
