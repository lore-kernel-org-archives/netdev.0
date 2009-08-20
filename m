From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [GIT PULL 0/5] IEEE 802.15.4 updates
Date: Thu, 20 Aug 2009 20:13:02 +0400
Message-ID: <1250784787-30590-1-git-send-email-dbaryshkov@gmail.com>
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net,
	Sergey Lapin <slapin@ossfans.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f207.google.com ([209.85.219.207]:63200 "EHLO
	mail-ew0-f207.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751790AbZHTQOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2009 12:14:04 -0400
Received: by ewy3 with SMTP id 3so5527ewy.18
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2009 09:14:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The following changes since commit 886f9fe68310168358f55028a03553ae154dfeb6:
  David S. Miller (1):
        ppp_generic: Help GCC see that 'flen' is always initialized.

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/lowpan/lowpan.git for-next

Dmitry Eremin-Solenikov (5):
      ieee802154: document the skb->cb usage clearly.
      ieee802154: add a sysfs representation of WPAN master devices
      fakehard: add binding to wpan-phy device
      ieee802154: add support for channel pages from IEEE 802.15.4-2006
      Drop ARPHRD_IEEE802154_PHY

 Documentation/networking/ieee802154.txt |    9 ++-
 drivers/ieee802154/fakehard.c           |   62 ++++++++++--
 include/linux/if_arp.h                  |    1 -
 include/linux/nl802154.h                |    2 +
 include/net/ieee802154_netdev.h         |    6 +-
 include/net/nl802154.h                  |    2 +-
 include/net/wpan-phy.h                  |   63 ++++++++++++
 net/core/dev.c                          |    4 +-
 net/ieee802154/Makefile                 |    2 +-
 net/ieee802154/af_ieee802154.c          |    4 +-
 net/ieee802154/netlink.c                |   28 +++++-
 net/ieee802154/nl_policy.c              |    1 +
 net/ieee802154/raw.c                    |    3 +-
 net/ieee802154/wpan-class.c             |  159 +++++++++++++++++++++++++++++++
 14 files changed, 318 insertions(+), 28 deletions(-)
 create mode 100644 include/net/wpan-phy.h
 create mode 100644 net/ieee802154/wpan-class.c

-- 
With best wishes
Dmitry

