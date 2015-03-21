From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 0/4] isdn/gigaset: restructure modem response parser
Date: Sat, 21 Mar 2015 20:15:32 +0100 (CET)
Message-ID: <cover.1426964840.git.tilman@imap.cc>
Cc: David Miller <davem@davemloft.net>, Hansjoerg Lipp <hjlipp@web.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pxnet.com ([89.1.7.7]:43445 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751604AbbCUTt6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2015 15:49:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches restructures the Gigaset ISDN driver's
modem response parser to improve code readability and conform
better to the device's specification and actual behaviour.
Could you please merge these through net-next?

Thanks,
Tilman

Tilman Schmidt (4):
  isdn/gigaset: restructure modem response parser (1)
  isdn/gigaset: restructure modem response parser (2)
  isdn/gigaset: restructure modem response parser (3)
  isdn/gigaset: restructure modem response parser (4)

 drivers/isdn/gigaset/ev-layer.c | 365 +++++++++++++++++++++-------------------
 1 file changed, 195 insertions(+), 170 deletions(-)

-- 
1.9.2.459.g68773ac
