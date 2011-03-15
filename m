From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 0/2][pull request] Intel Wired LAN Driver Update
Date: Mon, 14 Mar 2011 22:54:22 -0700
Message-ID: <1300168464-29546-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:60787 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752136Ab1COFy2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Mar 2011 01:54:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains a fix for timestamping and the
addition of thermal sensor support for igb.

The following are changes since commit 0c0217b016ba8a970a6f6ab62ad0d858f39881ca:
  net: dcbnl: Add IEEE app selector value definitions
and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6 master

Anders Berggren (1):
  igb: fix hw timestamping

Carolyn Wyborny (1):
  igb: Add messaging for thermal sensor events on i350 devices

 drivers/net/igb/e1000_defines.h |    5 ++++
 drivers/net/igb/e1000_regs.h    |    3 ++
 drivers/net/igb/igb_main.c      |   42 +++++++++++++++++++++++++++++++++++++-
 3 files changed, 48 insertions(+), 2 deletions(-)

-- 
1.7.4

