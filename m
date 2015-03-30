From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH net-next] net: smc91x: Remove an unused variable
Date: Mon, 30 Mar 2015 19:20:57 +0200
Message-ID: <20150330172057.GG17728@pengutronix.de>
References: <1427733818-11823-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Fabio Estevam <fabio.estevam@freescale.com>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:47309 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753253AbbC3RVC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 13:21:02 -0400
Content-Disposition: inline
In-Reply-To: <1427733818-11823-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 30, 2015 at 01:43:38PM -0300, Fabio Estevam wrote:
> From: Fabio Estevam <fabio.estevam@freescale.com>
>=20
> Commit cb6e0b3690f48dff ("net: smc91x: make use of 4th parameter to d=
evm_gpiod_get_index")
> caused the following build warning:
>=20
> drivers/net/ethernet/smsc/smc91x.c:2208:6: warning: unused variable '=
res' [-Wunused-variable]
>=20
> Remove the unused 'res' variable.
>=20
> Reported-by: Olof's autobuilder <build@lixom.net>
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
I wonder why I didn't notice this because the 0day build robot tested m=
y
tree and didn't report this warning. Probably that means this driver
wasn't tested.

Acked-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
