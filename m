From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 0/3][pull request] Intel Wired LAN Driver Updates
Date: Fri, 28 Jan 2011 04:29:36 -0800
Message-ID: <1296217779-30133-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:46329 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755140Ab1A1M3q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jan 2011 07:29:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains the addition of ixgbe ethtool support
for 100MB FULL and the addition of igb PF support for i350 devices as
well as VF transmit rate limit using iproute2.

The following are changes since commit a4daad6b0923030fbd3b00a01f570e4c3eef446b:
  net: Pre-COW metrics for TCP.

and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6 master

Atita Shirwaikar (1):
  ixgbe: Adding 100MB FULL support in ethtool

Carolyn Wyborny (1):
  igb: Enable PF side of SR-IOV support for i350 devices

Lior Levy (1):
  igb: add support for VF Transmit rate limit using iproute2

 drivers/net/igb/e1000_82575.c     |   10 +++-
 drivers/net/igb/e1000_defines.h   |    7 +++
 drivers/net/igb/e1000_mbx.c       |   38 ++++++-------
 drivers/net/igb/e1000_regs.h      |    4 ++
 drivers/net/igb/igb.h             |    2 +
 drivers/net/igb/igb_main.c        |  105 +++++++++++++++++++++++++++++++++++--
 drivers/net/ixgbe/ixgbe_ethtool.c |   34 +++++++++++-
 drivers/net/ixgbe/ixgbe_main.c    |    5 ++-
 8 files changed, 176 insertions(+), 29 deletions(-)

-- 
1.7.3.5

