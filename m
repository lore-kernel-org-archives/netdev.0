From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH] fec: Unify fec_ptp.c and fec.c
Date: Thu, 21 Mar 2013 11:09:49 +0100
Message-ID: <20130321100949.GO20530@pengutronix.de>
References: <1363810268-24398-1-git-send-email-festevam@gmail.com>
 <20130321062146.GL20530@pengutronix.de>
 <CAHrpEqTd2mVaTW6pwJaHqYreDo6rT_6s_o=Z=OtU71PZzZCSVg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fabio Estevam <festevam@gmail.com>, davem@davemloft.net,
	Frank.Li@freescale.com, netdev@vger.kernel.org,
	Fabio Estevam <fabio.estevam@freescale.com>
To: Frank Li <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:55171 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753140Ab3CUKJz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 06:09:55 -0400
Content-Disposition: inline
In-Reply-To: <CAHrpEqTd2mVaTW6pwJaHqYreDo6rT_6s_o=Z=OtU71PZzZCSVg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Thu, Mar 21, 2013 at 06:02:02PM +0800, Frank Li wrote:
> I suggest use below patch to fix this problem
>=20
> --- a/drivers/net/ethernet/freescale/Makefile
> +++ b/drivers/net/ethernet/freescale/Makefile
> @@ -2,7 +2,8 @@
>  # Makefile for the Freescale network device drivers.
>  #
>=20
> -obj-$(CONFIG_FEC) +=3D fec.o fec_ptp.o
> +obj-$(CONFIG_FEC) +=3D fec_driver.o
> +fec_driver-objs :=3D fec.o fec_ptp.o
>  obj-$(CONFIG_FEC_MPC52xx) +=3D fec_mpc52xx.o
>  ifeq ($(CONFIG_FEC_MPC52xx_MDIO),y)
>         obj-$(CONFIG_FEC_MPC52xx) +=3D fec_mpc52xx_phy.o
I thought about suggesting something similar, too. I would have renamed
fec.c to (say) fec_base.c and then kept the module name fec.ko. Not sur=
e
keeping the module name is critical.

What is missing from your patch is dropping the EXPORT_SYMBOLs. Other
than that I like it better than using a single .c file.

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
