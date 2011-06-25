From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/9][pull request] Intel Wired LAN Driver Update
Date: Sat, 25 Jun 2011 00:22:17 -0700
Message-ID: <1308986546-12964-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:31485 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750893Ab1FYHW2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 03:22:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to ixgbe.  The changes are mainly
cleanup/update of the ixgbe driver.

The following are changes since commit c6af9c406ceb3434281cf230938453931dcbab75:
  net: wimax: Remove of unused 'rfkill_input' pointer
and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6 master

Alexander Duyck (5):
  ixgbe: pass adapter struct instead of netdev for interrupt data
  ixgbe: Convert IXGBE_DESC_UNUSED from macro to static inline function
  ixgbe: Move all values that deal with count, next_to_use,
    next_to_clean to u16
  ixgbe: Add one function that handles most of context descriptor setup
  ixgbe: Update method used for determining descriptor count for an skb

John Fastabend (3):
  ixgbe: complete FCoE initialization from setapp() routine
  ixgbe: remove unused fcoe.tc field and fcoe_setapp()
  ixgbe: implement DCB ops dcb_ieee_del()

Lior Levy (1):
  ixgbe: A fix to VF TX rate limit

 drivers/net/ixgbe/ixgbe.h        |   21 ++-
 drivers/net/ixgbe/ixgbe_dcb_nl.c |   74 ++++++--
 drivers/net/ixgbe/ixgbe_fcoe.c   |  139 +++-----------
 drivers/net/ixgbe/ixgbe_fcoe.h   |    1 -
 drivers/net/ixgbe/ixgbe_main.c   |  390 +++++++++++++++++---------------------
 drivers/net/ixgbe/ixgbe_sriov.c  |   16 ++
 drivers/net/ixgbe/ixgbe_type.h   |    2 +-
 7 files changed, 298 insertions(+), 345 deletions(-)

-- 
1.7.5.4

