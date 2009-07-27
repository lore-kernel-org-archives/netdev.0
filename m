From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PULL REQ][PATCH 0/3] ieee 802.15.4 documentation updates
Date: Mon, 27 Jul 2009 18:08:12 +0400
Message-ID: <1248703695-7043-1-git-send-email-dbaryshkov@gmail.com>
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net,
	Sergey Lapin <slapin@ossfans.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:33909 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750764AbZG0OIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 10:08:34 -0400
Received: by fg-out-1718.google.com with SMTP id e21so828874fga.17
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2009 07:08:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please pull 3 small updates for IEEE 802.15.4 code (documentation and headers move).

The following changes since commit 72dccb01e8632aa5ffe58070003d0fa19d007116:
  Eric Dumazet (1):
        bnx2: Update vlan_features

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/lowpan/lowpan.git for-linus

Daniel Silverstone (1):
      IEEE80154: Add documentation to the IEEE80154 netlink and fakehard driver

Dmitry Eremin-Solenikov (1):
      ieee802154: move headers out of extra directory

Thadeu Lima de Souza Cascardo (1):
      trivial: fix typo in ieee802154 documentation and add it to index

 Documentation/networking/00-INDEX                  |    2 +
 Documentation/networking/ieee802154.txt            |    2 +-
 drivers/ieee802154/fakehard.c                      |  128 +++++++++++++++++++-
 include/net/{ieee802154 => }/af_ieee802154.h       |    0
 include/net/{ieee802154/mac_def.h => ieee802154.h} |    4 +-
 include/net/ieee802154/nl802154.h                  |   41 ------
 .../netdevice.h => ieee802154_netdev.h}            |    0
 include/net/nl802154.h                             |  117 ++++++++++++++++++
 net/ieee802154/af_ieee802154.c                     |    4 +-
 net/ieee802154/dgram.c                             |    6 +-
 net/ieee802154/netlink.c                           |    6 +-
 net/ieee802154/raw.c                               |    2 +-
 12 files changed, 255 insertions(+), 57 deletions(-)
 rename include/net/{ieee802154 => }/af_ieee802154.h (100%)
 rename include/net/{ieee802154/mac_def.h => ieee802154.h} (98%)
 delete mode 100644 include/net/ieee802154/nl802154.h
 rename include/net/{ieee802154/netdevice.h => ieee802154_netdev.h} (100%)
 create mode 100644 include/net/nl802154.h
