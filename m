From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 0/4] ISDN patches for net-next
Date: Fri, 3 Oct 2014 17:03:32 +0200
Message-ID: <cover.1412348612.git.tilman@imap.cc>
Cc: David Miller <davem@davemloft.net>, Hansjoerg Lipp <hjlipp@web.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pxnet.com ([89.1.7.7]:41729 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752711AbaJCQ2L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Oct 2014 12:28:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here's a series of patches for the ISDN CAPI subsystem and the
Gigaset ISDN driver.  Please merge via net-next.

Tilman Schmidt (4):
  isdn/gigaset: improve error handling when leaving DLE mode
  isdn/gigaset: drop unused cardstate structure member
  isdn/gigaset: use USB API function usb_endpoint_num()
  isdn/capi: drop two dead if branches

 drivers/isdn/capi/capiutil.c       |    3 ---
 drivers/isdn/gigaset/ev-layer.c    |    3 ++-
 drivers/isdn/gigaset/usb-gigaset.c |   14 +++++---------
 3 files changed, 7 insertions(+), 13 deletions(-)
