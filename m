From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 0/3] bonding: style, comment and assertion changes
Date: Mon, 15 Sep 2014 17:19:32 +0200
Message-ID: <1410794375-7386-1-git-send-email-nikolay@redhat.com>
Cc: vfalico@gmail.com, j.vosburgh@gmail.com, andy@greyhouse.net,
	davem@davemloft.net, Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6658 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752959AbaIOPUC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Sep 2014 11:20:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,
This is a small and simple patch-set that doesn't introduce (hopefully) any
functional changes, but only stylistic and semantic ones.
Patch 01 simply uses the already provided __rlb_next_rx_slave function inside
rlb_next_rx_slave(), thus removing the duplication of code.
Patch 02 changes all comments that I could find to netdev style, removes
some outdated ones and fixes a few more small cosmetic issues (new line
after declaration, braces around if; else and such)
Patch 03 removes one extra ASSERT_RTNL() because we already have it in the
parent function and consolidates two other ASSERT_RTNL()s to the function
that is exported and supposed to be called with RTNL anyway.

Best regards,
 Nikolay Aleksandrov

Nikolay Aleksandrov (3):
  bonding: consolidate the two rlb_next_rx_slave functions into one
  bonding: trivial: style and comment fixes
  bonding: consolidate ASSERT_RTNL()s and remove the unnecessary

 drivers/net/bonding/bond_3ad.c     |   5 +-
 drivers/net/bonding/bond_alb.c     |  86 ++++++----------
 drivers/net/bonding/bond_debugfs.c |   4 +-
 drivers/net/bonding/bond_main.c    | 205 +++++++++++++------------------------
 drivers/net/bonding/bond_sysfs.c   |   1 -
 drivers/net/bonding/bonding.h      |   3 +-
 6 files changed, 105 insertions(+), 199 deletions(-)

-- 
1.9.3
