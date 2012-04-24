From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH 0/5][6lowpan] several fixes for 6lowpan
Date: Tue, 24 Apr 2012 14:51:06 +0400
Message-ID: <1335264671-27127-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: davem@davemloft.net, linux-zigbee-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:63896 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752359Ab2DXKvi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 06:51:38 -0400
Received: by bkuw12 with SMTP id w12so313831bku.19
        for <netdev@vger.kernel.org>; Tue, 24 Apr 2012 03:51:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Dear David,

the following patch-set contains several fixes/improvements for 6lowpan:
1. fix: segmentation fault caused by mlme request
2. impr: move frame allocation code to a separate function
3. fix: clean up fragments list if module unloaded
4. impr: duplicate definition of IEEE802154_ALEN
5. fix: add missing spin_lock_init()

Could you please review them?

With best regards,
Alex

8<--

The following changes since commit ac807fa8e625aff58060876d70298c93a59c4252:

  tcp: Fix build warning after tcp_{v4,v6}_init_sock consolidation. (2012-04-23 03:21:58 -0400)

are available in the git repository at:
  git://local ..BRANCH.NOT.VERIFIED..

Alexander Smirnov (5):
      6lowpan: fix segmentation fault caused by mlme request
      6lowpan: move frame allocation code to a separate function
      6lowpan: clean up fragments list if module unloaded
      6lowpan: duplicate definition of IEEE802154_ALEN
      6lowpan: add missing spin_lock_init()

 net/ieee802154/6lowpan.c |  125 ++++++++++++++++++++++++++++++++--------------
 net/ieee802154/6lowpan.h |    3 -
 2 files changed, 88 insertions(+), 40 deletions(-)
