From: Asbjoern Sloth Toennesen <asbjorn@asbjorn.biz>
Subject: [PATCH 0/7] e1000e: cleanup
Date: Thu,  9 Dec 2010 02:40:50 +0000
Message-ID: <1291862457-16671-1-git-send-email-asbjorn@asbjorn.biz>
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This patchset fixes most checkstyle problems in e1000e.

Checkpatch summary:
pre:	total:	221 errors,	129 warnings,	24520 lines checked
post:	total:	2 errors,	34 warnings,	24533 lines checked

The two remaining errors are of the type "Macros with complex values
should be enclosed in parenthesis", with macros containing 3 comma
seperated values.

The remaining warnings are all caused by <20ms msleep usage, that should
be replaced with usleep_range calls.

This patchset is based on top of jkirsher/net-next-2.6.git (67d5288)

Asbjoern Sloth Toennesen (7):
  e1000e: cleanup: fix spacing issues
  e1000e: cleanup: fix bracket issues
  e1000e: cleanup: simplify E1000_ALL_* defines
  e1000e: cleanup: fix long lines
  e1000e: cleanup: fix space issues in ich8_* structs
  e1000e: cleanup: swap arguments to avoid checkpatch errors
  e1000e: cleanup: fix copyright notices to preferred style

 drivers/net/e1000e/82571.c   |   70 +++++++-------
 drivers/net/e1000e/defines.h |  110 ++++++++++++-----------
 drivers/net/e1000e/e1000.h   |   93 +++++++++++---------
 drivers/net/e1000e/es2lan.c  |  135 ++++++++++++++--------------
 drivers/net/e1000e/ethtool.c |   75 ++++++++--------
 drivers/net/e1000e/hw.h      |   56 ++++++------
 drivers/net/e1000e/ich8lan.c |  185 +++++++++++++++++++-------------------
 drivers/net/e1000e/lib.c     |   78 ++++++++--------
 drivers/net/e1000e/netdev.c  |  171 +++++++++++++++++------------------
 drivers/net/e1000e/param.c   |   60 +++++++------
 drivers/net/e1000e/phy.c     |  204 +++++++++++++++++++++---------------------
 11 files changed, 625 insertions(+), 612 deletions(-)

-- 
1.7.2.3
