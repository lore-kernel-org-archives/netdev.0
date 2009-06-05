From: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PULL REQUEST] IEEE 802.15.4 stack: generic parts v2
Date: Fri,  5 Jun 2009 06:29:45 +0400
Message-ID: <1244168990-28355-1-git-send-email-dbaryshkov@gmail.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello,

This is a second version of pull/merge request for our IEEE 802.15.4 stack.
Major changes from previous post:
 * Several macroses replaced with inline functions to ensure type correctness.
 * Reformat source to (mostly) fit into 80 columns
 * Drop constants 'reservation' declarations from headers
 * Split policy from nl802154.h to separate source file.
 * Add documentation for our netlink protocol.

The following changes since commit 9fa7eb283c5cdc2b0f4a8cfe6387ed82e5e9a3d3:
  Linus Torvalds (1):
        Linux 2.6.30-rc8

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/lumag/lowpan.git for-next

Dmitry Eremin-Solenikov (5):
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
 net/ieee802154/nl_policy.c              |   65 ++++
 net/ieee802154/raw.c                    |  254 +++++++++++++++
 27 files changed, 2557 insertions(+), 3 deletions(-)
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

-- 
With best wishes
Dmitry

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
