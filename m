From: Veaceslav Falico <vfalico@gmail.com>
Subject: [PATCH net-next 00/12] bonding: convert pr_* to netdev_*
Date: Tue, 15 Jul 2014 19:35:57 +0200
Message-ID: <1405445769-15394-1-git-send-email-vfalico@gmail.com>
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53378 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755031AbaGORkf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2014 13:40:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently bonding uses pr_info/warn/etc. function to print something, while
it's encouraged to use netdev_info/warn/etc. in net/.

This patchset converts them where possible (i.e. where we have a working
net_device). Also, convert pr_ratelimit* to net_() and remove the pr_fmt,
to unify netdev_* and pr_* outputs.


CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@gmail.com>

---
 drivers/net/bonding/bond_3ad.c     | 185 ++++++++++++++--------------
 drivers/net/bonding/bond_alb.c     |  36 +++---
 drivers/net/bonding/bond_debugfs.c |   6 +-
 drivers/net/bonding/bond_main.c    | 344 +++++++++++++++++++++++++----------------------------
 drivers/net/bonding/bond_netlink.c |  11 +-
 drivers/net/bonding/bond_options.c | 218 ++++++++++++++++-----------------
 drivers/net/bonding/bond_procfs.c  |   4 +-
 7 files changed, 373 insertions(+), 431 deletions(-)
