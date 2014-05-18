From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 0/4] ISDN patches for net-next
Date: Sun, 18 May 2014 23:26:08 +0200
Message-ID: <cover.1400448368.git.tilman@imap.cc>
Cc: Paul Bolle <pebolle@tiscali.nl>, isdn4linux@listserv.isdn4linux.de,
	"Keil, Karsten" <isdn@linux-pingi.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([89.1.7.7]:43908 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752150AbaERWnP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 May 2014 18:43:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here's a series of patches for the ISDN CAPI subsystem and an auxiliary
patch to the tty driver, prepared by Paul Bolle over the last couple of
weeks. I would appreciate if you could merge these via net-next.

Paul Bolle (4):
  isdn/capi: move capi_info2str to capidrv.c
  isdn/capi: Make verbose reporting depend on capidrv
  tty: allow tty drivers to rename their device nodes
  isdn/capi: fix (middleware) device nodes

 drivers/isdn/capi/Kconfig     |  18 ++--
 drivers/isdn/capi/capi.c      |   8 +-
 drivers/isdn/capi/capidrv.c   | 195 ++++++++++++++++++++++++++++++++++++++++
 drivers/isdn/capi/capiutil.c  | 200 ------------------------------------------
 drivers/tty/tty_io.c          |  16 +++-
 include/linux/isdn/capiutil.h |   5 --
 include/linux/tty_driver.h    |   1 +
 7 files changed, 226 insertions(+), 217 deletions(-)

-- 
1.9.2.459.g68773ac
