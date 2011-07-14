From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 00/10] net: random cleanups
Date: Thu, 14 Jul 2011 02:10:29 +0200 (CEST)
Message-ID: <cover.1310601401.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:59811 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752448Ab1GNAKb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2011 20:10:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a set of random cleanups accumulated while digging through the
network device drivers. Only patches that don't depend on removing
old ethtool ops are included here.

The series consists of patches that can be applied independently from
others from the set. The exception is patch #7 that depends on removing
NETIF_F_NO_CSUM references in patches 1, 2 and 5.

---

Micha=C5=82 Miros=C5=82aw (10):
  net: sctp: fix checksum marking for outgoing packets
  net: m68k/nfeth: Remove wrong usage of dev->flags
  net: vlan: remove reduntant check in ndo_fix_features callback
  net: cleanup vlan_features setting in register_netdev
  net: Disable NOCACHE_COPY by default
  net: remove NETIF_F_ALL_TX_OFFLOADS
  net: remove NETIF_F_NO_CSUM feature
  net: unexport netdev_fix_features()
  net: remove /sys/class/net/*/features
  net: remove SK_ROUTE_CAPS from meta ematch

 arch/m68k/emu/nfeth.c                |    1 -
 drivers/ieee802154/fakehard.c        |    2 +-
 drivers/misc/sgi-xp/xpnet.c          |    2 +-
 drivers/net/bonding/bond_main.c      |    8 ++++----
 drivers/net/can/dev.c                |    2 +-
 drivers/net/can/slcan.c              |    2 +-
 drivers/net/dummy.c                  |    2 +-
 drivers/net/ifb.c                    |    2 +-
 drivers/net/loopback.c               |    2 +-
 drivers/net/veth.c                   |    2 +-
 include/linux/netdevice.h            |   10 +---------
 include/linux/skbuff.h               |    1 -
 include/linux/tc_ematch/tc_em_meta.h |    2 +-
 net/8021q/vlan_dev.c                 |   11 +++++++----
 net/bridge/br_device.c               |    4 ++--
 net/core/dev.c                       |   33 +++++++++-----------------=
-------
 net/core/ethtool.c                   |    2 +-
 net/core/net-sysfs.c                 |    2 --
 net/sched/em_meta.c                  |    7 -------
 net/sctp/output.c                    |   19 ++++++++-----------
 20 files changed, 41 insertions(+), 75 deletions(-)

--=20
1.7.5.4

