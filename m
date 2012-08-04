From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: [net 0/3][pull request] Intel Wired LAN Driver Updates
Date: Sat,  4 Aug 2012 03:25:49 -0700
Message-ID: <1344075952-4198-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Cc: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:13166 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751760Ab2HDK0H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Aug 2012 06:26:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains various fixes to the igb driver.

The following are changes since commit ff6e1225957cce9e93b8d84dc240e5a44094d0ec:
  cris: fix eth_v10.c build error
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/ppwaskie/net master

Carolyn Wyborny (1):
  igb: Fix for failure to init on some 82576 devices.

Jesper Juhl (2):
  igb: correct hardware type (i210/i211) check in igb_loopback_test()
  igb: don't break user visible strings over multiple lines in
    igb_ethtool.c

 drivers/net/ethernet/intel/igb/e1000_82575.c |   16 ++++++++--------
 drivers/net/ethernet/intel/igb/igb_ethtool.c |   25 ++++++++++++-------------
 2 files changed, 20 insertions(+), 21 deletions(-)

-- 
1.7.10.4
