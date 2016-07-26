From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH 0/2] net: davinci_cpdma: reduce latency on -rt
Date: Tue, 26 Jul 2016 14:02:23 +0200
Message-ID: <1469534545-14478-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-omap@vger.kernel.org, netdev@vger.kernel.org,
	kernel@pengutronix.de
To: Mugunthan V N <mugunthanvnm@ti.com>,
	Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:42842 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753724AbcGZMC6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 08:02:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

these patches are based on next-20160726. I didn't check yet how latenc=
y
improves by using these patches, but even if the improvment is small,
it's still a good idea to have them.

A second pair of eyes checking what I did would be great.

Best regards
Uwe


Uwe Kleine-K=C3=B6nig (2):
  net: davinci_cpdma: reduce time holding ctlr->lock in
    cpdma_control_set
  net: davinci_cpdma: reduce time holding chan->lock in
    cpdma_chan_submit

 drivers/net/ethernet/ti/davinci_cpdma.c | 58 ++++++++++++++++---------=
--------
 1 file changed, 29 insertions(+), 29 deletions(-)

--=20
2.8.1
