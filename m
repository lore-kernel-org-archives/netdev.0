From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: only clear a queue's work bit if the queue
 was emptied
Date: Wed, 04 May 2016 14:09:10 -0400 (EDT)
Message-ID: <20160504.140910.2171362814117515274.davem@davemloft.net>
References: <1462286333-23402-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fugang.duan@nxp.com, kernel@pengutronix.de, netdev@vger.kernel.org
To: u.kleine-koenig@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41117 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755167AbcEDSJN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 14:09:13 -0400
In-Reply-To: <1462286333-23402-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
Date: Tue,  3 May 2016 16:38:53 +0200

> In the receive path a queue's work bit was cleared unconditionally ev=
en
> if fec_enet_rx_queue only read out a part of the available packets fr=
om
> the hardware. This resulted in not reading any packets in the next na=
pi
> turn and so packets were delayed or lost.
>=20
> The obvious fix is to only clear a queue's bit when the queue was
> emptied.
>=20
> Fixes: 4d494cdc92b3 ("net: fec: change data structure to support mult=
iqueue")
> Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>

Applied and queued up for -stable, thanks.
