From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 0/4] gigaset: patches for 2.6.34
Date: Tue, 23 Feb 2010 00:08:21 +0100 (CET)
Message-ID: <20100221-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <keil@b1-systems.de>,
	isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Karsten, David,

following are four patches to the Gigaset driver I'd like you to
forward for merging into kernel release 2.6.34.

Thanks,
Tilman

Andy Shevchenko (1):
  isdn: remove ishexdigit() in regard to isxdigit()

Tilman Schmidt (3):
  gigaset: small documentation improvement
  bas_gigaset: collapse CR/LF at end of AT response
  gigaset: reduce syslog clutter

 Documentation/isdn/README.gigaset  |   10 ++---
 drivers/isdn/gigaset/asyncdata.c   |    6 ++-
 drivers/isdn/gigaset/bas-gigaset.c |   18 +++-------
 drivers/isdn/gigaset/capi.c        |   31 ++----------------
 drivers/isdn/gigaset/common.c      |   49 +++++++++++-----------------
 drivers/isdn/gigaset/ev-layer.c    |   63 ++++++++++++++++++-------------------
 drivers/isdn/gigaset/gigaset.h     |   11 ++----
 drivers/isdn/gigaset/i4l.c         |   52 +++---------------------------
 drivers/isdn/gigaset/interface.c   |   12 ++-----
 drivers/isdn/gigaset/isocdata.c    |   44 ++++++++++++++++++-------
 drivers/isdn/gigaset/proc.c        |    2 -
 drivers/isdn/gigaset/usb-gigaset.c |    2 -
