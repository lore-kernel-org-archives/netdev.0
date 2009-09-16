From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [GIT PULL 0/2] Fixes for IEEE 802.15.4
Date: Wed, 16 Sep 2009 17:22:11 +0400
Message-ID: <1253107333-25043-1-git-send-email-dbaryshkov@gmail.com>
Cc: linux-zigbee-devel@lists.sourceforge.net,
	Sergey Lapin <slapin@ossfans.org>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f206.google.com ([209.85.219.206]:38276 "EHLO
	mail-ew0-f206.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750812AbZIPNW4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2009 09:22:56 -0400
Received: by ewy2 with SMTP id 2so1405814ewy.17
        for <netdev@vger.kernel.org>; Wed, 16 Sep 2009 06:22:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, David,

Please pull both into net/master and net-next/master (as I'd like
to submit few patches into net-next/master depending on this).

The following changes since commit 4e36a95e591e9c58dd10bb4103c00993917c27fd:
  David Howells (1):
        RxRPC: Use uX/sX rather than uintX_t/intX_t types

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/lowpan/lowpan.git for-linus

Dmitry Eremin-Solenikov (2):
      af_ieee802154: setsockopt optlen arg isn't __user
      ieee802154: add locking for seq numbers

 net/ieee802154/dgram.c   |    2 +-
 net/ieee802154/netlink.c |    4 ++++
 net/ieee802154/raw.c     |    2 +-
 3 files changed, 6 insertions(+), 2 deletions(-)

