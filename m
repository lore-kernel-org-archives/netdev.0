From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH net-next] net: smc91x: Remove an unused variable
Date: Tue, 31 Mar 2015 19:38:01 +0200
Message-ID: <20150331173800.GJ17728@pengutronix.de>
References: <1427733818-11823-1-git-send-email-festevam@gmail.com>
 <20150330172057.GG17728@pengutronix.de>
 <20150331.105328.2195438658331769456.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: festevam@gmail.com, netdev@vger.kernel.org,
	fabio.estevam@freescale.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:53623 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753029AbbCaRiF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 13:38:05 -0400
Content-Disposition: inline
In-Reply-To: <20150331.105328.2195438658331769456.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 31, 2015 at 10:53:28AM -0400, David Miller wrote:
> From: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
> Date: Mon, 30 Mar 2015 19:20:57 +0200
>=20
> > On Mon, Mar 30, 2015 at 01:43:38PM -0300, Fabio Estevam wrote:
> >> From: Fabio Estevam <fabio.estevam@freescale.com>
> >>=20
> >> Commit cb6e0b3690f48dff ("net: smc91x: make use of 4th parameter t=
o devm_gpiod_get_index")
> >> caused the following build warning:
> >>=20
> >> drivers/net/ethernet/smsc/smc91x.c:2208:6: warning: unused variabl=
e 'res' [-Wunused-variable]
> >>=20
> >> Remove the unused 'res' variable.
> >>=20
> >> Reported-by: Olof's autobuilder <build@lixom.net>
> >> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
> > I wonder why I didn't notice this because the 0day build robot test=
ed my
> > tree and didn't report this warning. Probably that means this drive=
r
> > wasn't tested.
>=20
> This driver can't be enabled on x86/x86-64 so the build testing it wi=
ll
> get is going to be extremely limited.
The build bot also builds other archs, at least arm and powerpc, but I
think there are more.

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
