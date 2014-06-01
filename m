From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 0/3] ISDN patches for net-next (v2)
Date: Sun,  1 Jun 2014 23:47:24 +0200 (CEST)
Message-ID: <cover.1401475962.git.tilman@imap.cc>
Cc: David Miller <davem@davemloft.net>,
	Paul Bolle <pebolle@tiscali.nl>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de, Jiri Slaby <jslaby@suse.cz>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([89.1.7.7]:55007 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752441AbaFAVvM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Jun 2014 17:51:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here's v2 of the series of patches for the ISDN CAPI subsystem
prepared by Paul Bolle and reviewed by yours truly. It reflects
GregKH's review, resulting in a substantial simplification.
Please merge via net-next.

Paul Bolle (3):
  isdn/capi: move capi_info2str to capidrv.c
  isdn/capi: Make verbose reporting depend on capidrv
  isdn/capi: fix (middleware) device nodes

 drivers/isdn/capi/Kconfig     |  18 ++--
 drivers/isdn/capi/capi.c      |   4 +-
 drivers/isdn/capi/capidrv.c   | 195 ++++++++++++++++++++++++++++++++++++++++
 drivers/isdn/capi/capiutil.c  | 200 ------------------------------------------
 include/linux/isdn/capiutil.h |   5 --
 5 files changed, 206 insertions(+), 216 deletions(-)

-- 
1.9.2.459.g68773ac
