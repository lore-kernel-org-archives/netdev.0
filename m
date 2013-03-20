From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH] fec: Fix the build as module
Date: Wed, 20 Mar 2013 20:16:30 +0100
Message-ID: <20130320191630.GJ20530@pengutronix.de>
References: <1363803572-17039-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, Frank.Li@freescale.com,
	netdev@vger.kernel.org, Fabio Estevam <fabio.estevam@freescale.com>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:49423 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752066Ab3CTTQe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 15:16:34 -0400
Content-Disposition: inline
In-Reply-To: <1363803572-17039-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Wed, Mar 20, 2013 at 03:19:32PM -0300, Fabio Estevam wrote:
> From: Fabio Estevam <fabio.estevam@freescale.com>
>=20
> Since commit ff43da86c69 (NET: FEC: dynamtic check DMA desc buff type=
) the=20
> following build error happens when CONFIG_FEC=3Dm
>=20
> ERROR: "fec_ptp_init" [drivers/net/ethernet/freescale/fec.ko] undefin=
ed!
> ERROR: "fec_ptp_ioctl" [drivers/net/ethernet/freescale/fec.ko] undefi=
ned!
> ERROR: "fec_ptp_start_cyclecounter" [drivers/net/ethernet/freescale/f=
ec.ko] undefined!
>=20
> Fix it by exporting the required fec_ptp symbols.
IMHO this is not sensible. There is no need to make the fec driver 2
modules. Just loading one is impossible (fec.ko) or useless
(fec_ptp.ko). That's why I suggested to make them a single module.

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
