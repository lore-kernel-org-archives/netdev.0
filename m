From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 0/9] Gigaset patches for net-next
Date: Fri,  1 Oct 2010 01:34:20 +0200 (CEST)
Message-ID: <20100930-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <keil@b1-systems.de>,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Karsten, David,

here's a series of nine patches to the Gigaset driver.
Please consider for application to net-next-2.6.
The first three should also go into -stable and are
tagged "CC: stable" accordingly.

Thanks,
Tilman

Tilman Schmidt (9):
      isdn/gigaset: bas_gigaset locking fix
      isdn/gigaset: fix bas_gigaset AT read error handling
      isdn/gigaset: correct oom handling in data receive path
      isdn/gigaset: drop obsolete debug option
      isdn/gigaset: bas_gigaset timer cleanup
      isdn/gigaset: try USB reset for bas_gigaset error recovery
      isdn/gigaset: unclog bas_gigaset AT response pipe
      isdn/gigaset: fix bas_gigaset interrupt read error handling
      isdn/gigaset: improve USB error reporting

 drivers/isdn/gigaset/bas-gigaset.c |  400 ++++++++++++++++++++++--------------
 drivers/isdn/gigaset/common.c      |   26 ---
 drivers/isdn/gigaset/gigaset.h     |    3 +-
 drivers/isdn/gigaset/i4l.c         |    2 -
 drivers/isdn/gigaset/isocdata.c    |    8 +-
 5 files changed, 254 insertions(+), 185 deletions(-)
