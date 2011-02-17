From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 0/4][pull request] Intel Wired LAN Driver Updates
Date: Thu, 17 Feb 2011 01:35:06 -0800
Message-ID: <1297935310-23510-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:45687 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754063Ab1BQJfQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Feb 2011 04:35:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains two fixes for e1000e and ixgbe.

The following are changes since commit 6d90e8f45697c633f522269368297d7416fd8783:
  isdn: hisax: Use l2headersize() instead of dup (and buggy) func.

and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-2.6 master

Amir Hanania (1):
  ixgbe: work around for DDP last buffer size

Andy Gospodarek (1):
  ixgbe: fix panic due to uninitialised pointer

Jesse Brandeburg (2):
  e1000e: check down flag in tasks
  e1000e: flush all writebacks before unload

 drivers/net/e1000e/netdev.c    |   52 ++++++++++++++++++++++++++++++++-------
 drivers/net/ixgbe/ixgbe_fcoe.c |   51 ++++++++++++++++++++++++++++++++++++++-
 drivers/net/ixgbe/ixgbe_fcoe.h |    2 +
 drivers/net/ixgbe/ixgbe_main.c |    6 +++-
 4 files changed, 98 insertions(+), 13 deletions(-)

-- 
1.7.4

