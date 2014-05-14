From: Veaceslav Falico <vfalico@gmail.com>
Subject: [PATCH net-next 0/5] bonding: simple macro cleanup
Date: Wed, 14 May 2014 14:54:19 +0200
Message-ID: <1400072064-26095-1-git-send-email-vfalico@gmail.com>
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50003 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754688AbaENM66 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2014 08:58:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

That's a trivial patchset that tries to unify the macro usage of bonding
modes. I've split it into two approaches - either BOND_*, which takes
bonding struct as a param, or MODE_*, which takes the mode itself. Also,
introduce BOND_MODE(bond) instead of ugly bond->params.mode.


CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: netdev@vger.kernel.org
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

---
 drivers/net/bonding/bond_alb.c         |   4 +-
 drivers/net/bonding/bond_debugfs.c     |   2 +-
 drivers/net/bonding/bond_main.c        | 114 ++++++++++++++++-----------------
 drivers/net/bonding/bond_netlink.c     |   6 +-
 drivers/net/bonding/bond_options.c     |   6 +-
 drivers/net/bonding/bond_procfs.c      |  14 ++--
 drivers/net/bonding/bond_sysfs.c       |  14 ++--
 drivers/net/bonding/bond_sysfs_slave.c |   2 +-
 drivers/net/bonding/bonding.h          |  24 +++----
 9 files changed, 91 insertions(+), 95 deletions(-)
