From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [GIT PULL 0/5] IEEE 802.15.4 last-minute fixes.
Date: Tue,  4 Aug 2009 02:51:37 +0400
Message-ID: <1249339902-10613-1-git-send-email-dbaryshkov@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Sergey Lapin <slapin@ossfans.org>,
	linux-zigbee-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:62550 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753200AbZHCWwL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2009 18:52:11 -0400
Received: by bwz19 with SMTP id 19so2741163bwz.37
        for <netdev@vger.kernel.org>; Mon, 03 Aug 2009 15:52:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

Please pull several minor fixes for the IEEE 802.15.4 stack.

The following changes since commit e4c4e448cf557921ffbbbd6d6ddac81fdceacb4f:
  Eric Dumazet (1):
        neigh: Convert garbage collection from softirq to workqueue

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/lowpan/lowpan.git for-linus

Dmitry Eremin-Solenikov (5):
      af_ieee802154: drop IEEE802154_SIOC_ADD_SLAVE declaration
      af_ieee802154: fix ioctl processing
      nl802154: make ieee802154_policy constant
      documentation: fix wrt. headers rename
      af_ieee802154: provide dummy get/setsockopt

 Documentation/networking/ieee802154.txt |    9 ++++-----
 include/linux/nl802154.h                |    2 +-
 include/net/af_ieee802154.h             |    3 ---
 net/ieee802154/af_ieee802154.c          |    8 +++++---
 net/ieee802154/dgram.c                  |   14 ++++++++++++++
 net/ieee802154/nl_policy.c              |    3 ++-
 net/ieee802154/raw.c                    |   14 ++++++++++++++
 7 files changed, 40 insertions(+), 13 deletions(-)

-- 
With best wishes
Dmitry

