From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH] fec: Unify fec_ptp.c and fec.c
Date: Thu, 21 Mar 2013 07:21:46 +0100
Message-ID: <20130321062146.GL20530@pengutronix.de>
References: <1363810268-24398-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, Frank.Li@freescale.com,
	netdev@vger.kernel.org, Fabio Estevam <fabio.estevam@freescale.com>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:60778 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754117Ab3CUGVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 02:21:50 -0400
Content-Disposition: inline
In-Reply-To: <1363810268-24398-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Fabio,

On Wed, Mar 20, 2013 at 05:11:07PM -0300, Fabio Estevam wrote:
> Currently CONFIG_FEC=3Dy generates two separate modules: fec_ptp.ko a=
nd fec.ko.
CONFIG_FEC=3Dm

> These modules cannot be used independently, so it is better to unify =
them.
>=20
> Move fec_ptp.c code into fec.c and its definitions into fec.h.
>=20
> Suggested-by: Uwe Kleine-Koenig <u.kleine-koenig@pengutronix.de>
s/Koe/K=F6/

> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

You could note that you dropped the EXPORT_SYMBOLs. Other than that I
assume it's a 1:1 change?

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
