From: Veaceslav Falico <vfalico@gmail.com>
Subject: [PATCH v2 net-next 0/9] bonding: simple macro cleanup
Date: Thu, 15 May 2014 14:29:18 +0200
Message-ID: <1400156967-8231-1-git-send-email-vfalico@gmail.com>
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2065 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751287AbaEOMeD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2014 08:34:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Trivial patchset that converts most of the bonding's macros into inline
functions. It introduces only one macro, BOND_MODE(), which is just
bond->params.mode, better to write/understand/remember.

The only real change is the removal of IFF_UP verification, which always
came in pair with && netif_running(), and is though useless, as it's always
IFF_UP when LINK_STATE_RUNNING.

v1->v2: use inlined functions instead of macros.

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: netdev@vger.kernel.org
Signed-off-by: Veaceslav Falico <vfalico@gmail.com>

---
 drivers/net/bonding/bond_3ad.c         |   6 +-
 drivers/net/bonding/bond_alb.c         |  18 ++---
 drivers/net/bonding/bond_debugfs.c     |   2 +-
 drivers/net/bonding/bond_main.c        | 143 ++++++++++++++++-----------------
 drivers/net/bonding/bond_netlink.c     |   6 +-
 drivers/net/bonding/bond_options.c     |  10 +--
 drivers/net/bonding/bond_procfs.c      |  14 ++--
 drivers/net/bonding/bond_sysfs.c       |  14 ++--
 drivers/net/bonding/bond_sysfs_slave.c |   2 +-
 drivers/net/bonding/bonding.h          |  84 +++++++++----------
 10 files changed, 145 insertions(+), 154 deletions(-)
