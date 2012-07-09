From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH net-next 0/6] ieee802.15.4 general fixes
Date: Mon,  9 Jul 2012 14:22:25 +0400
Message-ID: <1341829351-18485-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:33420 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752996Ab2GIK0f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 06:26:35 -0400
Received: by bkwj10 with SMTP id j10so5787740bkw.19
        for <netdev@vger.kernel.org>; Mon, 09 Jul 2012 03:26:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear David, Eric,

this patch-set is mostly intended to fix sparse and LOCKDEP warnings.
It contains some my previous patches reworked and extended according
to the hints from Eric Dumazet and Fengguang Wu. Many thanks to they!

With best regards,
Alex

Alexander Smirnov (6):
  6lowpan: revert: add missing spin_lock_init()
  drivers/ieee802154/at86rf230: rework irq handler
  mac802154: add get short address method
  6lowpan: rework fragment-deleting routine
  6lowpan: get extra headroom in allocated frame
  mac802154: sparse warnings: make symbols static

 drivers/ieee802154/at86rf230.c |   14 ++++++--------
 net/ieee802154/6lowpan.c       |   36 +++++++++++++++++++-----------------
 net/mac802154/mac802154.h      |    1 +
 net/mac802154/mac_cmd.c        |    4 +++-
 net/mac802154/mib.c            |   16 +++++++++++++++-
 5 files changed, 44 insertions(+), 27 deletions(-)

--
1.7.2.3
