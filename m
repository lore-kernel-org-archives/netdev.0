From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 00/11] ISDN patches for 2.6.36
Date: Tue,  6 Jul 2010 02:18:32 +0200 (CEST)
Message-ID: <20100705-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <keil@b1-systems.de>,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Karsten, David,

following are a series of patches to the Gigaset driver I'd like
to see included in kernel release 2.6.36.

Thanks,
Tilman

Tilman Schmidt (11):
      isdn/gigaset: make tty write buffer limit consistent
      isdn/gigaset: avoid copying AT commands twice
      isdn/gigaset: ignore irrelevant device responses
      isdn/gigaset: drop debug check on isochronous write
      isdn/gigaset: improve CAPI message debugging
      isdn/gigaset: handle Supplementary Service Listen
      isdn/gigaset: remove obsolete compile time options
      isdn/gigaset: reduce syslog spam
      isdn/gigaset: fix leaks in error path
      isdn/gigaset: document dial-out number format
      isdn/gigaset: remove EXPERIMENTAL tag from GIGASET_CAPI option

 Documentation/isdn/README.gigaset  |  117 +++++++++++++++++------------
 drivers/isdn/gigaset/Kconfig       |    4 -
 drivers/isdn/gigaset/bas-gigaset.c |   69 ++---------------
 drivers/isdn/gigaset/capi.c        |   70 ++++++++++++-----
 drivers/isdn/gigaset/common.c      |    2 
 drivers/isdn/gigaset/ev-layer.c    |  148 ++++++++++++-------------------------
 drivers/isdn/gigaset/gigaset.h     |   16 ----
 drivers/isdn/gigaset/i4l.c         |    4 -
 drivers/isdn/gigaset/interface.c   |   37 +++++++--
 drivers/isdn/gigaset/ser-gigaset.c |   27 +-----
 drivers/isdn/gigaset/usb-gigaset.c |   29 +------
 11 files changed, 226 insertions(+), 297 deletions(-)
