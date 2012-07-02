From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH net-next 0/0] fix sparse warnings
Date: Mon,  2 Jul 2012 10:18:30 +0400
Message-ID: <1341209912-6030-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org, dbaryshkov@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:65056 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932148Ab2GBGWn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 02:22:43 -0400
Received: by wibhr14 with SMTP id hr14so2818354wib.1
        for <netdev@vger.kernel.org>; Sun, 01 Jul 2012 23:22:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

I've received a notification from Fengguang Wu that there are new sparse
warnings are shown up after my patch sets.

Completely forgot about 'sparse', aghhr...

These patches fixes the following sparse warnings:
 - drivers/ieee802154/at86rf230.c:610:2: warning:
   'rc' may be used uninitialized in this function [-Wuninitialized]
 - net/ieee802154/6lowpan.c:127:12: sparse:
   symbol 'flist_lock' was not declared. Should it be static?
 - net/mac802154/mac_cmd.c:58:17: warning:
   symbol 'mac802154_get_phy' was not declared. Should it be static?
 - net/mac802154/mib.c:42:23: warning:
   symbol 'mac802154_slave_get_priv' was not declared. Should it be static?

With best regards,
Alexander Smirnov

Alexander Smirnov (2):
  ieee802154: sparse warnings: make symbols static
  drivers/ieee802154/at231rf230: remove unused return status

 drivers/ieee802154/at86rf230.c |    3 +--
 net/ieee802154/6lowpan.c       |    2 +-
 net/mac802154/mac_cmd.c        |    2 +-
 net/mac802154/mib.c            |    2 +-
 4 files changed, 4 insertions(+), 5 deletions(-)

--
1.7.2.3
