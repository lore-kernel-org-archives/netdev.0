From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [NEXT][PATCH 0/5] Updates for net-next for IEEE 802.15.4 code
Date: Thu, 30 Jun 2011 16:37:43 +0400
Message-ID: <1309437468-31021-1-git-send-email-dbaryshkov@gmail.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37174 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751031Ab1F3MiB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2011 08:38:01 -0400
Received: by wyg8 with SMTP id 8so1510445wyg.19
        for <netdev@vger.kernel.org>; Thu, 30 Jun 2011 05:38:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Please merge the following changes into the net-next repo:

The following changes since commit 1049f6413f6e52572a768ca1590fa479ef0a48e8:

  myri10ge: Update MAINTAINERS (2011-06-29 06:02:05 -0700)

are available in the git repository at:
  git://git2.kernel.org/pub/scm/linux/kernel/git/lowpan/lowpan.git for-next

Alexander Smirnov (1):
      ieee802154: free skb buffer if dev isn't running

Dmitry Eremin-Solenikov (3):
      fakehard: stop setting platform_data as it's unused anymore
      ieee802154: support specifying hw address for created devices
      ieee802154: it's IEEE 802.15.4, not ZigBee

Werner Almesberger (1):
      IEEE 802.15.4: do not enable driver debugging by default

 drivers/ieee802154/Makefile    |    2 --
 drivers/ieee802154/fakehard.c  |    2 --
 net/ieee802154/af_ieee802154.c |    2 +-
 net/ieee802154/dgram.c         |    2 +-
 net/ieee802154/nl-phy.c        |   31 +++++++++++++++++++++++++++++++
 5 files changed, 33 insertions(+), 6 deletions(-)
