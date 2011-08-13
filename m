From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/4][pull request] Intel Wired LAN Drive Update
Date: Sat, 13 Aug 2011 02:23:36 -0700
Message-ID: <1313227420-9974-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:12891 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751008Ab1HMJXm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Aug 2011 05:23:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to e1000e and ixgbe.

The following are changes since commit d80bcf46f1dae47805260dc60fb900cc4dabe35e:
  Merge branch 'for-davem' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless
and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net master

Alexander Duyck (1):
  ixgbe: Fix FCOE memory leak for DDP packets

Bruce Allan (3):
  e1000e: Spurious interrupts & dropped packets with 82577/8/9 in
    half-duplex
  e1000e: workaround for packet drop on 82579 at 100Mbps
  e1000e: workaround invalid Tx/Rx tail descriptor register write

 drivers/net/e1000e/e1000.h     |    4 ++
 drivers/net/e1000e/ich8lan.c   |   65 ++++++++++++++++++++++++++------
 drivers/net/e1000e/netdev.c    |   80 ++++++++++++++++++++++++++++++++++++++--
 drivers/net/ixgbe/ixgbe_main.c |    4 +-
 4 files changed, 135 insertions(+), 18 deletions(-)

-- 
1.7.6

