From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 0/7][pull request] Intel Wired LAN Driver Updates
Date: Thu, 27 Jan 2011 22:18:48 -0800
Message-ID: <1296195535-2990-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56196 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752885Ab1A1GS4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jan 2011 01:18:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains the addition of a PHY id for e1000
and several ixgbe fixes.

The following are changes since commit 4bb9ebc78097376b3734c6d3001a96aecac0f7bb:
  bnx2: Eliminate AER error messages on systems not supporting it

and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-2.6 master

Alexander Duyck (1):
  ixgbe: limit VF access to network traffic

Amir Hanania (1):
  ixgbe: DDP last buffer size work around

Don Skidmore (3):
  ixgbe: fix for 82599 erratum on Header Splitting.
  ixgbe: cleanup variable initialization
  ixgbe: update version string

Emil Tantilov (1):
  ixgbe: fix variable set but not used warnings by gcc 4.6

Florian Fainelli (1):
  e1000: add support for Marvell Alaska M88E1118R PHY

 drivers/net/e1000/e1000_hw.c     |    4 +++-
 drivers/net/e1000/e1000_hw.h     |    1 +
 drivers/net/ixgbe/ixgbe_common.c |    3 +++
 drivers/net/ixgbe/ixgbe_fcoe.c   |   21 ++++++++++++++++++++-
 drivers/net/ixgbe/ixgbe_main.c   |   16 ++++++++++------
 drivers/net/ixgbe/ixgbe_sriov.c  |    2 --
 drivers/net/ixgbe/ixgbe_x540.c   |    6 +++---
 7 files changed, 40 insertions(+), 13 deletions(-)

-- 
1.7.3.5

