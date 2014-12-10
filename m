From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 0/5] ISDN patches for net-next
Date: Wed, 10 Dec 2014 13:41:55 +0100 (CET)
Message-ID: <cover.1418214588.git.tilman@imap.cc>
Cc: David Miller <davem@davemloft.net>, Hansjoerg Lipp <hjlipp@web.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([89.1.7.7]:33187 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753902AbaLJM7w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Dec 2014 07:59:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here's a series of patches for the Gigaset ISDN driver and one for
the ISDN CAPI subsystem.  Please merge as appropriate.

Thanks,
Tilman

Tilman Schmidt (5):
  isdn/gigaset: drop duplicate declaration
  isdn/gigaset: clarify gigaset_modem_fill control structure
  isdn/gigaset: elliminate unnecessary argument from send_cb()
  isdn/gigaset: enable Kernel CAPI support by default
  isdn/capi: correct argument types of command_2_index

 drivers/isdn/capi/capiutil.c       |  2 +-
 drivers/isdn/gigaset/Kconfig       |  2 +-
 drivers/isdn/gigaset/gigaset.h     |  3 --
 drivers/isdn/gigaset/usb-gigaset.c | 77 ++++++++++++++++++--------------------
 4 files changed, 38 insertions(+), 46 deletions(-)

-- 
1.9.2.459.g68773ac
