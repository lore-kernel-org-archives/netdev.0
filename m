From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 0/5] late Gigaset fixes for 2.6.35
Date: Tue, 22 Jun 2010 01:54:04 +0200 (CEST)
Message-ID: <20100622-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <keil@b1-systems.de>,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Karsten, David,

following are five patches to the Gigaset driver fixing reported
problems with two CAPI applications (Asterisk and capifax). They
fix serious bugs, though not technically regressions, and I would
therefore appreciate if they could still make it into release
2.6.35. Otherwise please queue them for the first stable cycle.

These should also go into 2.6.34-stable. They apply cleanly to
2.6.34 except for some offsets in file drivers/isdn/gigaset/capi.c.

I'll follow up with a series of less urgent patches which I'll
propose for eventual inclusion in release 2.6.36.

Thanks,
Tilman

Tilman Schmidt (5):
      isdn/gigaset: honor CAPI application's buffer size request
      isdn/gigaset: correct CAPI voice connection encoding
      isdn/gigaset: correct CAPI DATA_B3 Delivery Confirmation
      isdn/gigaset: encode HLC and BC together
      isdn/gigaset: correct CAPI connection state storage

 drivers/isdn/gigaset/asyncdata.c |   44 +---
 drivers/isdn/gigaset/capi.c      |  407 ++++++++++++++++++++++++++-----------
 drivers/isdn/gigaset/common.c    |   36 ++---
 drivers/isdn/gigaset/ev-layer.c  |    4 +-
 drivers/isdn/gigaset/gigaset.h   |   38 +++--
 drivers/isdn/gigaset/i4l.c       |   21 ++
 drivers/isdn/gigaset/isocdata.c  |   72 +++-----
 7 files changed, 382 insertions(+), 240 deletions(-)
