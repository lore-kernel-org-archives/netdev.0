From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 0/8] ISDN patches for net-next
Date: Thu, 26 Apr 2012 01:02:19 +0200 (CEST)
Message-ID: <20120425-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <keil@b1-systems.de>,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([89.1.7.7]:36957 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932434Ab2DYXDE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2012 19:03:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Karsten, David,

here's a series of eight patches to the Kernel CAPI subsystem and
the Gigaset driver. Please consider for application to net-next.
The first three should also go into -stable and are tagged accordingly.

Thanks,
Tilman

Tilman Schmidt (8):
      isdn/gigaset: ratelimit CAPI message dumps
      isdn/gigaset: fix CAPI disconnect B3 handling
      isdn/gigaset: improve error handling querying firmware version
      isdn/gigaset: fix readability damage 
      isdn/gigaset: internal function name cleanup
      isdn/gigaset: unify function return values
      isdn/capi: fix readability damage
      isdn/capi: elliminate capincci_find() in non-middleware case

 drivers/isdn/capi/capi.c           |   50 ++---
 drivers/isdn/capi/capidrv.c        |    8 
 drivers/isdn/gigaset/bas-gigaset.c |   44 ++---
 drivers/isdn/gigaset/capi.c        |  118 ++++++-------
 drivers/isdn/gigaset/common.c      |   59 ++----
 drivers/isdn/gigaset/dummyll.c     |    2 
 drivers/isdn/gigaset/ev-layer.c    |  321 ++++++++++++++++++-------------------
 drivers/isdn/gigaset/gigaset.h     |   30 +--
 drivers/isdn/gigaset/i4l.c         |   12 -
 drivers/isdn/gigaset/isocdata.c    |   12 -
 drivers/isdn/gigaset/ser-gigaset.c |   21 +-
 drivers/isdn/gigaset/usb-gigaset.c |   19 +-
 12 files changed, 341 insertions(+), 355 deletions(-)
