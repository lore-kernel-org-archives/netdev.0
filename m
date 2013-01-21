From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 0/6] ISDN patches for net-next
Date: Mon, 21 Jan 2013 22:57:20 +0100 (CET)
Message-ID: <20130121-patch-isdn-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <keil@b1-systems.de>,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Karsten, David,

here's a series of six patches to the ISDN subsystem. Please consider
for application to net-next. The last one should also go into -stable
and is tagged "CC: stable" accordingly.

Thanks,
Tilman

Tilman Schmidt (6):
      isdn/divert: fix readability damage
      isdn/gigaset: leave DLE mode before hanging up
      isdn/gigaset: beautify interface.c
      isdn/gigaset: beautify common.c
      isdn/gigaset: beautify ev-layer.c
      isdn/gigaset: fix zero size border case in debug dump

 drivers/isdn/divert/divert_init.c |   33 +-
 drivers/isdn/divert/isdn_divert.c |  423 ++++++++++++++++++--------------------
 drivers/isdn/divert/isdn_divert.h |   28 +-
 drivers/isdn/gigaset/capi.c       |    2 
 drivers/isdn/gigaset/common.c     |   31 --
 drivers/isdn/gigaset/ev-layer.c   |  124 +++++------
 drivers/isdn/gigaset/gigaset.h    |    9 
 drivers/isdn/gigaset/interface.c  |   46 +---
 8 files changed, 332 insertions(+), 364 deletions(-)
