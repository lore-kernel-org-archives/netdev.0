From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: [net 0/3][pull request] Intel Wired LAN Driver Updates
Date: Tue,  7 Aug 2012 01:04:14 -0700
Message-ID: <1344326657-9376-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Cc: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:49719 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751274Ab2HGIFi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Aug 2012 04:05:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains fixes to the e1000e and igb drivers.

The following are changes since commit 5d299f3d3c8a2fbc732b1bf03af36333ccec3130:
  
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/ppwaskie/net master

Stefan Assmann (1):
  igb: add delay to allow igb loopback test to succeed on 8086:10c9

Tushar Dave (2):
  e1000e: NIC goes up and immediately goes down
  e1000e: 82571 Tx Data Corruption during Tx hang recovery

 drivers/net/ethernet/intel/e1000e/82571.c    | 10 +++++-----
 drivers/net/ethernet/intel/igb/igb_ethtool.c |  3 +++
 2 files changed, 8 insertions(+), 5 deletions(-)

-- 
1.7.11.2
