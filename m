From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH 0/3] net: ipconfig: improve DHCP timeout handling
Date: Fri, 29 Jul 2016 11:30:36 +0200
Message-ID: <1469784639-15705-1-git-send-email-u.kleine-koenig@pengutronix.de>
References: <20160728112613.n72e6pein3b5lm4b@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kernel@pengutronix.de,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Chris Friesen <cfriesen@nortel.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:59517 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752731AbcG2JbM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2016 05:31:12 -0400
In-Reply-To: <20160728112613.n72e6pein3b5lm4b@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

this series teaches the ipconfig code to handle a DHCP reply on eth0 ev=
en if a
request on eth1 was already sent out.
This is a follow fix to 2513dfb83fc7 ("ipconfig: handle case of delayed=
 DHCP
server") that dropped a late reply.

This makes it possible at all to work with slow DHCP servers at all in =
some
configurations and improves boot speed in general.

The first patch is not really necessary, it only helps decoding debug m=
essages
when there is more than one device.

Best regards
Uwe

Uwe Kleine-K=C3=B6nig (3):
  net: ipconfig: Add device name to debug messages
  net: ipconfig: Support using "delayed" DHCP replies
  net: ipconfig: drop inter-device timeout

 net/ipv4/ipconfig.c | 50 +++++++++++++++++++++------------------------=
-----
 1 file changed, 21 insertions(+), 29 deletions(-)

--=20
2.8.1
