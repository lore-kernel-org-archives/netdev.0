From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 0/3][pull request] Intel Wired LAN Driver Updates
Date: Wed,  2 Mar 2011 03:45:38 -0800
Message-ID: <1299066341-13820-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:21428 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756749Ab1CBLqo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2011 06:46:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains fixes for sparse warnings for e1000
and igb, as well as a fix for e1000e.

The following are changes since commit e3fa3aff0cb198e7c53d894f52146121d9592872:
  net: fix nla_policy_len to actually _iterate_ over the policy

and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-2.6 master

Bruce Allan (1):
  e1000e: disable broken PHY wakeup for ICH10 LOMs, use MAC wakeup
    instead

Jeff Kirsher (1):
  igb: fix sparse warning

Stephen Hemminger (1):
  e1000: fix sparse warning

 drivers/net/e1000/e1000_osdep.h |    3 ++-
 drivers/net/e1000e/netdev.c     |    3 ++-
 drivers/net/igbvf/vf.c          |    2 +-
 3 files changed, 5 insertions(+), 3 deletions(-)

-- 
1.7.4

