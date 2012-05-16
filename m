From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH net-next v5 0/13] basic ieee802.15.4 mac support
Date: Wed, 16 May 2012 10:50:18 +0400
Message-ID: <1337151031-5178-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org, dbaryshkov@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:61280 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759140Ab2EPGvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 02:51:32 -0400
Received: by wibhn6 with SMTP id hn6so372487wib.1
        for <netdev@vger.kernel.org>; Tue, 15 May 2012 23:51:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This is the 5-th version of patch series for IEEE 802.15.4 Medium Access
Control layer support.

Changes since the last post:
 - All the comments were polished to the same style
 - Some new extra comments were added

Best regards,
Alex

8<--

Alexander Smirnov (13):
  mac802154: basic ieee802.15.4 device structures
  mac802154: allocation of ieee802154 device
  mac802154: RX data path
  mac802154: TX data path
  mac802154: define reduced mlme operations
  mac802154: slave interfaces definition
  mac802154: basic MAC commands interface support
  mac802154: basic mib support
  ieee802154: interface type to be added
  mac802154: slaves management support
  mac802154: monitor device support
  drivers/ieee802154: IEEE 802.15.4 loopback driver
  Documentation/networking/ieee802154: update MAC chapter

 Documentation/networking/ieee802154.txt |   75 ++++++--
 drivers/ieee802154/Kconfig              |    8 +
 drivers/ieee802154/Makefile             |    1 +
 drivers/ieee802154/fakelb.c             |  294 +++++++++++++++++++++++++++++++
 include/linux/if_arp.h                  |    1 +
 include/linux/nl802154.h                |   20 ++
 include/net/ieee802154_netdev.h         |   27 +++-
 include/net/mac802154.h                 |  136 ++++++++++++++
 include/net/wpan-phy.h                  |   10 +-
 net/Kconfig                             |    1 +
 net/Makefile                            |    1 +
 net/ieee802154/nl-phy.c                 |    9 +-
 net/mac802154/Kconfig                   |   16 ++
 net/mac802154/Makefile                  |    2 +
 net/mac802154/ieee802154_dev.c          |  294 +++++++++++++++++++++++++++++++
 net/mac802154/mac802154.h               |  109 ++++++++++++
 net/mac802154/mac_cmd.c                 |   45 +++++
 net/mac802154/mib.c                     |   93 ++++++++++
 net/mac802154/monitor.c                 |  116 ++++++++++++
 net/mac802154/rx.c                      |  114 ++++++++++++
 net/mac802154/tx.c                      |  116 ++++++++++++
 21 files changed, 1465 insertions(+), 23 deletions(-)
 create mode 100644 drivers/ieee802154/fakelb.c
 create mode 100644 include/net/mac802154.h
 create mode 100644 net/mac802154/Kconfig
 create mode 100644 net/mac802154/Makefile
 create mode 100644 net/mac802154/ieee802154_dev.c
 create mode 100644 net/mac802154/mac802154.h
 create mode 100644 net/mac802154/mac_cmd.c
 create mode 100644 net/mac802154/mib.c
 create mode 100644 net/mac802154/monitor.c
 create mode 100644 net/mac802154/rx.c
 create mode 100644 net/mac802154/tx.c

--
1.7.2.3
