From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: (unknown)
Date: Thu, 18 Jun 2009 18:26:12 +0400
Message-ID: <1245335177-16810-1-git-send-email-dbaryshkov@gmail.com>
Cc: linux-kernel@vger.kernel.org, Sergey Lapin <slapin@ossfans.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f210.google.com ([209.85.219.210]:58265 "EHLO
	mail-ew0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753724AbZFRO0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 10:26:36 -0400
Subject: 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From Dmitry Eremin-Solenikov <dbaryshkov@gmail.com> # This line is ignored.
GIT:
From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [RFC][PATCH 0/5] Please review the data-only IEEE 802.15.4 MAC implementation
In-Reply-To: 

Hello,

I'd like to submit several our next patches for linux-next inclusion
(most probably not yet for 2.6.31 though). Could you please review them?

The following changes since commit 81e2a3d5b75cbf0b42428b9d5a7cc7c85be9e7a7:
  Eric Dumazet (1):
        atm: sk_wmem_alloc initial value is one

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/lowpan/lowpan.git for-next

Darren Salt (1):
      crc-itu-t: add bit-reversed calculation

Dmitry Eremin-Solenikov (5):
      ieee802154: use standard routine for printing dumps
      mac802154: add a software MAC 802.15.4 implementation
      ieee802154: add virtual loopback driver
      MAINTAINERS: fix IEEE 802.15.4 entry
      Merge branch 'for-linus' into for-next

 MAINTAINERS                        |    5 +-
 drivers/ieee802154/Kconfig         |   13 +
 drivers/ieee802154/Makefile        |    1 +
 drivers/ieee802154/fakelb.c        |  345 +++++++++++++++
 include/linux/crc-itu-t.h          |   10 +
 include/linux/if.h                 |    2 +
 include/net/ieee802154/mac802154.h |   83 ++++
 lib/Kconfig                        |    1 +
 lib/crc-itu-t.c                    |   17 +
 net/Kconfig                        |    1 +
 net/Makefile                       |    1 +
 net/ieee802154/af_ieee802154.c     |   12 +-
 net/mac802154/Kconfig              |   17 +
 net/mac802154/Makefile             |    4 +
 net/mac802154/dev.c                |  845 ++++++++++++++++++++++++++++++++++++
 net/mac802154/mac802154.h          |   62 +++
 net/mac802154/mac_cmd.c            |   94 ++++
 net/mac802154/mdev.c               |  298 +++++++++++++
 net/mac802154/mib.h                |   32 ++
 net/mac802154/rx.c                 |   98 +++++
 20 files changed, 1930 insertions(+), 11 deletions(-)
 create mode 100644 drivers/ieee802154/fakelb.c
 create mode 100644 include/net/ieee802154/mac802154.h
 create mode 100644 net/mac802154/Kconfig
 create mode 100644 net/mac802154/Makefile
 create mode 100644 net/mac802154/dev.c
 create mode 100644 net/mac802154/mac802154.h
 create mode 100644 net/mac802154/mac_cmd.c
 create mode 100644 net/mac802154/mdev.c
 create mode 100644 net/mac802154/mib.h
 create mode 100644 net/mac802154/rx.c
