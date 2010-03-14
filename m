From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 0/3] gigaset fixes for 2.6.34-rc1
Date: Sun, 14 Mar 2010 23:58:05 +0100 (CET)
Message-ID: <cover.1268580322.git.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	isdn4linux <isdn4linux@listserv.isdn4linux.de>,
	i4ldeveloper <i4ldeveloper@listserv.isdn4linux.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pxnet.com ([195.227.45.7]:59831 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934304Ab0CNXBG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Mar 2010 19:01:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Karsten, David,

following are three bugfix patches to the Gigaset driver which should
still go into 2.6.34 if possible, and also into the 2.6.33 stable branch.

Thanks,
Tilman

Tilman Schmidt (3):
  gigaset: avoid registering CAPI driver more than once
  gigaset: correct clearing of at_state strings on RING
  gigaset: prune use of tty_buffer_request_room

 drivers/isdn/gigaset/capi.c      |   44 +++++++++++++++++++++----------------
 drivers/isdn/gigaset/common.c    |    6 +++-
 drivers/isdn/gigaset/ev-layer.c  |   12 +++-------
 drivers/isdn/gigaset/gigaset.h   |    6 +++-
 drivers/isdn/gigaset/i4l.c       |   28 +++++++++++++++++-------
 drivers/isdn/gigaset/interface.c |    1 -
 6 files changed, 57 insertions(+), 40 deletions(-)

