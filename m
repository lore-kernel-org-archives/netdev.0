From: Sergey Lapin <slapin@ossfans.org>
Subject: [PULL REQUEST] IEEE 802.15.4 stack: generic parts v4
Date: Tue,  9 Jun 2009 02:18:46 +0400
Message-ID: <cover.1244498867.git.slapin@ossfans.org>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	David Miller <davem@davemloft.net>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Sergey Lapin <slapin@ossfans.org>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from build.ossfans.org ([67.223.233.67]:43061 "EHLO
	build.ossfans.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754564AbZFHWS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 18:18:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

This is a fourth version of pull/merge request for IEEE 802.15.4 stack.

As per Dmitry request I'm taking over passing this patchset through
review. This is my first pull request through mail lists, so I might
do some mistakes, but I hope I did not miss any.

Major changes from previous post:
 * Changed net/ieee802154/Makefile according to Sam Ravnborg suggestion

The following changes since commit 81ee1bad86bd6752c626018d43a74e3f81f1ae72:
  Linus Torvalds (1):
        Merge branch 'for-linus' of git://git.kernel.org/.../viro/vfs-2.6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/slapin/lowpan.git for-next

Sergey Lapin (5):
      Add constants for the ieee 802.15.4 stack
      net: add IEEE 802.15.4 socket family implementation
      net: add NL802154 interface for configuration of 802.15.4 devices
      ieee802154: add documentation about our stack
      ieee802154: add simple HardMAC driver sample

 Documentation/networking/ieee802154.txt |   76 +++++
 MAINTAINERS                             |   12 +
 drivers/Makefile                        |    1 +
 drivers/ieee802154/Kconfig              |   22 ++
 drivers/ieee802154/Makefile             |    3 +
 drivers/ieee802154/fakehard.c           |  270 ++++++++++++++++
 drivers/net/Kconfig                     |    2 +
 include/linux/if_arp.h                  |    2 +
 include/linux/if_ether.h                |    1 +
 include/linux/nl802154.h                |  119 +++++++
 include/linux/socket.h                  |    4 +-
 include/net/ieee802154/af_ieee802154.h  |   60 ++++
 include/net/ieee802154/mac_def.h        |  160 ++++++++++
 include/net/ieee802154/netdevice.h      |  115 +++++++
 include/net/ieee802154/nl802154.h       |   41 +++
 net/Kconfig                             |    1 +
 net/Makefile                            |    1 +
 net/core/dev.c                          |    6 +-
 net/core/sock.c                         |    3 +
 net/ieee802154/Kconfig                  |   12 +
 net/ieee802154/Makefile                 |    5 +
 net/ieee802154/af802154.h               |   36 +++
 net/ieee802154/af_ieee802154.c          |  372 ++++++++++++++++++++++
 net/ieee802154/dgram.c                  |  394 +++++++++++++++++++++++
 net/ieee802154/netlink.c                |  523 +++++++++++++++++++++++++++++++
 net/ieee802154/nl_policy.c              |   52 +++
 net/ieee802154/raw.c                    |  254 +++++++++++++++
 27 files changed, 2544 insertions(+), 3 deletions(-)
 create mode 100644 Documentation/networking/ieee802154.txt
 create mode 100644 drivers/ieee802154/Kconfig
 create mode 100644 drivers/ieee802154/Makefile
 create mode 100644 drivers/ieee802154/fakehard.c
 create mode 100644 include/linux/nl802154.h
 create mode 100644 include/net/ieee802154/af_ieee802154.h
 create mode 100644 include/net/ieee802154/mac_def.h
 create mode 100644 include/net/ieee802154/netdevice.h
 create mode 100644 include/net/ieee802154/nl802154.h
 create mode 100644 net/ieee802154/Kconfig
 create mode 100644 net/ieee802154/Makefile
 create mode 100644 net/ieee802154/af802154.h
 create mode 100644 net/ieee802154/af_ieee802154.c
 create mode 100644 net/ieee802154/dgram.c
 create mode 100644 net/ieee802154/netlink.c
 create mode 100644 net/ieee802154/nl_policy.c
 create mode 100644 net/ieee802154/raw.c
