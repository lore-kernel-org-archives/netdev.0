From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 0/2] ISDN patches for 2.6.36
Date: Tue,  6 Jul 2010 02:18:16 +0200 (CEST)
Message-ID: <20100705-patch-isdn-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <keil@b1-systems.de>,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([89.1.7.7]:41921 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752128Ab0GFASl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jul 2010 20:18:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Karsten, David,

following are two patches to the ISDN subsystem I'd like to see
included in kernel release 2.6.36.

Thanks,
Tilman

Tilman Schmidt (2):
      isdn: CAPI controller interface documentation amendment
      isdn: avoid calling tty_ldisc_flush() in atomic context

 Documentation/isdn/INTERFACE.CAPI |    8 ++++++--
 drivers/isdn/i4l/isdn_tty.c       |    6 ------
 2 files changed, 6 insertions(+), 8 deletions(-)
