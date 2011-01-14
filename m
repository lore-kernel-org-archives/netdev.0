From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 0/3][pull-request] Intel Wired LAN Driver Updates
Date: Fri, 14 Jan 2011 03:42:27 -0800
Message-ID: <1295005350-28124-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:8193 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751572Ab1ANLmc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jan 2011 06:42:32 -0500
To: davem@davemloft.net
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains a fix for e1000 and trivial fixes
for e1000e.

The following are changes since commit 1949e084bfd143c76e22c0b37f370d6e7bf4bfdd:
  Merge branch 'master' of git://1984.lsi.us.es/net-2.6

and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-2.6 master

Bruce Allan (2):
  e1000e: update Copyright for 2011
  e1000e: consistent use of Rx/Tx vs. RX/TX/rx/tx in comments/logs

Jesse Brandeburg (1):
  e1000: Avoid unhandled IRQ

 drivers/net/e1000/e1000_main.c |   10 ++-
 drivers/net/e1000e/82571.c     |    4 +-
 drivers/net/e1000e/Makefile    |    2 +-
 drivers/net/e1000e/defines.h   |    2 +-
 drivers/net/e1000e/e1000.h     |    2 +-
 drivers/net/e1000e/es2lan.c    |    2 +-
 drivers/net/e1000e/ethtool.c   |    2 +-
 drivers/net/e1000e/hw.h        |    4 +-
 drivers/net/e1000e/ich8lan.c   |    2 +-
 drivers/net/e1000e/lib.c       |   20 ++--
 drivers/net/e1000e/netdev.c    |  223 ++++++++++++++++++++--------------------
 drivers/net/e1000e/param.c     |    6 +-
 drivers/net/e1000e/phy.c       |    4 +-
 13 files changed, 147 insertions(+), 136 deletions(-)

-- 
1.7.3.4

