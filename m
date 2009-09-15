From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [GIT PULL 0/7] Small IEEE 802.15.4 updates
Date: Wed, 16 Sep 2009 02:12:58 +0400
Message-ID: <1253052785-26190-1-git-send-email-dbaryshkov@gmail.com>
Cc: linux-zigbee-devel@lists.sourceforge.net,
	Sergey Lapin <slapin@ossfans.org>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f206.google.com ([209.85.219.206]:63125 "EHLO
	mail-ew0-f206.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751869AbZIOWNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2009 18:13:53 -0400
Received: by ewy2 with SMTP id 2so922640ewy.17
        for <netdev@vger.kernel.org>; Tue, 15 Sep 2009 15:13:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Dave,

Could you please pull small updates for IEEE 802.15.4 targeted
into 2.6.32-rcX. Thank you.


The following changes since commit 4142e0d1def2c0176c27fd2e810243045a62eb6d:
  Linus Torvalds (1):
        Merge branch 'osync_cleanup' of git://git.kernel.org/.../jack/linux-fs-2.6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/lowpan/lowpan.git for-next

Dmitry Eremin-Solenikov (7):
      af_ieee802154: setsockopt optlen arg isn't __user
      ieee802154: add locking for seq numbers
      ieee802154: add a helper to put the wpan_phy device
      ieee802154: add wpan-phy iteration functions
      ieee802154: merge nl802154 and wpan-class in single module
      nl802154: split away MAC commands implementation
      ieee802154: add LIST_PHY command support

 include/linux/nl802154.h    |    1 +
 include/net/wpan-phy.h      |    8 +
 net/ieee802154/Makefile     |    4 +-
 net/ieee802154/dgram.c      |    2 +-
 net/ieee802154/ieee802154.h |   48 ++++
 net/ieee802154/netlink.c    |  616 ++-----------------------------------------
 net/ieee802154/nl-mac.c     |  609 ++++++++++++++++++++++++++++++++++++++++++
 net/ieee802154/nl-phy.c     |  175 ++++++++++++
 net/ieee802154/raw.c        |    2 +-
 net/ieee802154/wpan-class.c |   48 ++++-
 10 files changed, 908 insertions(+), 605 deletions(-)
 create mode 100644 net/ieee802154/ieee802154.h
 create mode 100644 net/ieee802154/nl-mac.c
 create mode 100644 net/ieee802154/nl-phy.c


-- 
With best wishes
Dmitry

