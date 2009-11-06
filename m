From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [NEXT PULL 00/17] IEEE 802.15.4 stack updates.
Date: Fri,  6 Nov 2009 15:39:24 +0300
Message-ID: <1257511181-19403-1-git-send-email-dbaryshkov@gmail.com>
Cc: netdev@vger.kernel.org, Sergey Lapin <slapin@ossfans.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f207.google.com ([209.85.219.207]:58044 "EHLO
	mail-ew0-f207.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752365AbZKFMkf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 07:40:35 -0500
Received: by ewy3 with SMTP id 3so975605ewy.37
        for <netdev@vger.kernel.org>; Fri, 06 Nov 2009 04:40:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please pull into net-next an update for IEEE 802.15.4

The following changes since commit 6a2a2d6bf8581216e08be15fcb563cfd6c430e1e:
  Gilad Ben-Yossef (1):
        tcp: Use defaults when no route options are available

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/lowpan/lowpan.git for-next

Dmitry Eremin-Solenikov (17):
      wpan-phy: add a helper to put the wpan_phy device
      wpan-phy: add wpan-phy iteration functions
      wpan-phy: init channel/page fields
      wpan-phy: use snprintf to limit the amount of chars written
      wpan-phy: allow specifying a per-page channel mask
      wpan-phy: follow usual patter of devices registration
      ieee802154: constify struct net_device in some operations
      ieee802154: merge nl802154 and wpan-class in single module
      ieee802154: split away MAC commands implementation
      ieee802154: add LIST_PHY command support
      fakehard: no need to export net_to_phy, make it static
      fakehard: claim all 2.4 Ghz channels as supported
      ieee802154: add an mlme_ops call to retrieve PHY object
      fakehard: mlme_ops->get_phy implementation
      ieee802154: add two nl802154 helpers
      ieee802154: add PHY_NAME to LIST_IFACE command results
      ieee802154: add support for creation/removal of logic interfaces

 drivers/ieee802154/fakehard.c   |   59 +++-
 include/linux/nl802154.h        |    6 +
 include/net/ieee802154_netdev.h |   16 +-
 include/net/wpan-phy.h          |   22 ++-
 net/ieee802154/Makefile         |    4 +-
 net/ieee802154/ieee802154.h     |   53 ++++
 net/ieee802154/netlink.c        |  613 ++------------------------------------
 net/ieee802154/nl-mac.c         |  617 +++++++++++++++++++++++++++++++++++++++
 net/ieee802154/nl-phy.c         |  344 ++++++++++++++++++++++
 net/ieee802154/nl_policy.c      |    2 +
 net/ieee802154/wpan-class.c     |   77 +++++-
 11 files changed, 1202 insertions(+), 611 deletions(-)
 create mode 100644 net/ieee802154/ieee802154.h
 create mode 100644 net/ieee802154/nl-mac.c
 create mode 100644 net/ieee802154/nl-phy.c

