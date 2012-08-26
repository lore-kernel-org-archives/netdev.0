From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH 0/2]: ieee802154 drivers location
Date: Sun, 26 Aug 2012 19:10:09 +0400
Message-ID: <1345993811-13803-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org, dbaryshkov@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:65519 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750754Ab2HZPPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Aug 2012 11:15:48 -0400
Received: by wibhr14 with SMTP id hr14so2617479wib.1
        for <netdev@vger.kernel.org>; Sun, 26 Aug 2012 08:15:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please review these two patches:

1. I want to keep 'ieee802154' drivers with other networking code in
   'drivers/net' folder instead of current location in drivers root.
   I don't exactly know this historical reason, but lets keep networking
   code together.
2. Minor cosmetic improvement in at86rf230 driver

With best regards,
Alex

8<--
Alexander Smirnov (2):
  drivers/ieee802154/at86rf230: replace the code under _init and _exit
    by macro
  drivers/ieee802154: move ieee802154 drivers to net folder

 drivers/Makefile                   |    1 -
 drivers/ieee802154/Kconfig         |   36 --
 drivers/ieee802154/Makefile        |    3 -
 drivers/ieee802154/at86rf230.c     |  968 ------------------------------------
 drivers/ieee802154/fakehard.c      |  449 -----------------
 drivers/ieee802154/fakelb.c        |  294 -----------
 drivers/net/Kconfig                |    4 +-
 drivers/net/Makefile               |    1 +
 drivers/net/ieee802154/Kconfig     |   36 ++
 drivers/net/ieee802154/Makefile    |    3 +
 drivers/net/ieee802154/at86rf230.c |  958 +++++++++++++++++++++++++++++++++++
 drivers/net/ieee802154/fakehard.c  |  449 +++++++++++++++++
 drivers/net/ieee802154/fakelb.c    |  294 +++++++++++
 13 files changed, 1743 insertions(+), 1753 deletions(-)
 delete mode 100644 drivers/ieee802154/Kconfig
 delete mode 100644 drivers/ieee802154/Makefile
 delete mode 100644 drivers/ieee802154/at86rf230.c
 delete mode 100644 drivers/ieee802154/fakehard.c
 delete mode 100644 drivers/ieee802154/fakelb.c
 create mode 100644 drivers/net/ieee802154/Kconfig
 create mode 100644 drivers/net/ieee802154/Makefile
 create mode 100644 drivers/net/ieee802154/at86rf230.c
 create mode 100644 drivers/net/ieee802154/fakehard.c
 create mode 100644 drivers/net/ieee802154/fakelb.c

--
1.7.2.3
