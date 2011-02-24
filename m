From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 0/7][pull request] Intel Wired LAN Driver Updates
Date: Thu, 24 Feb 2011 02:58:22 -0800
Message-ID: <1298545109-8990-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:8720 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753123Ab1BXK6f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Feb 2011 05:58:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains jumbo frame support for X540 devices,
comment cleanup/fixes for ixgbevf & igb, and the addition of Tx rate
limiting feature for igb.

The following are changes since commit 55ae22d08fc9b531bc8a88b7306004e7053bb425:
 Merge branch 'tipc-Feb23-2011' of git://git.kernel.org/pub/scm/linux/kernel/git/paulg/net-next-2.6

and are available in the git repository at:
 master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6 master

Carolyn Wyborny (2):
  igb: Update Intel copyright notice for driver source.
  igb: update version string

Greg Rose (3):
  ixgbe: Enable Jumbo Frames on the X540 10Gigabit Controller
  ixgbevf: Enable jumbo frame support for X540 VF
  ixgbevf: Fix name of function in function header comment

Lior Levy (2):
  igbvf: remove Tx hang detection
  igb: add support for VF Transmit rate limit using iproute2

 drivers/net/igb/e1000_defines.h    |    7 +++
 drivers/net/igb/e1000_regs.h       |    4 ++
 drivers/net/igb/igb.h              |    2 +
 drivers/net/igb/igb_main.c         |   92 ++++++++++++++++++++++++++++++++++--
 drivers/net/igbvf/igbvf.h          |    3 -
 drivers/net/igbvf/netdev.c         |   60 -----------------------
 drivers/net/ixgbe/ixgbe_main.c     |   18 ++++++-
 drivers/net/ixgbe/ixgbe_sriov.c    |   29 +++++++++++-
 drivers/net/ixgbe/ixgbe_type.h     |    2 +
 drivers/net/ixgbevf/defines.h      |    2 +
 drivers/net/ixgbevf/ixgbevf_main.c |   35 ++++++++++----
 11 files changed, 174 insertions(+), 80 deletions(-)

-- 
1.7.4

