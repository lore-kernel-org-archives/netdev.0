From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/fec: Don't let ndo_start_xmit return
 NETDEV_TX_BUSY without link
Date: Tue, 30 Jul 2013 16:05:30 -0700 (PDT)
Message-ID: <20130730.160530.831845971567683172.davem@davemloft.net>
References: <1374758875-7926-1-git-send-email-u.kleine-koenig@pengutronix.de>
	<1375176580-7368-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, fabio.estevam@freescale.com,
	Frank.Li@freescale.com, shawn.guo@linaro.org,
	kernel@pengutronix.de, hector.palacios@digi.com,
	tim.sander@hbm.com, rostedt@goodmis.org, tglx@linutronix.de,
	stephen@networkplumber.org, B38611@freescale.com,
	florian@openwrt.org, bhutchings@solarflare.com
To: u.kleine-koenig@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43060 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756106Ab3G3XFe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 19:05:34 -0400
In-Reply-To: <1375176580-7368-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
Date: Tue, 30 Jul 2013 11:29:40 +0200

> Don't test for having link and let hardware deal with this situation.
>=20
> Without this patch I see a machine running an -rt patched Linux being
> stuck in sch_direct_xmit when it looses link while there is still a
> packet to be sent. In this case the fec_enet_start_xmit routine retur=
ned
> NETDEV_TX_BUSY which makes the network stack reschedule the packet an=
d
> so sch_direct_xmit calls fec_enet_start_xmit again.
> I failed to reproduce a complete hang without -rt, but I think the
> problem exists there, too.
>=20
> Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>

Applied, thanks.
