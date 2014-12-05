From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH 1/1] net: macb: Remove obsolete comment from Kconfig
Date: Fri, 5 Dec 2014 15:42:27 +0100
Message-ID: <5481C453.7060907@atmel.com>
References: <1417784633-13360-1-git-send-email-james.byrne@origamienergy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cyrille Pitchen <cyrille.pitchen@atmel.com>
To: James Byrne <james.byrne@origamienergy.com>,
	<netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.242]:53185 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750965AbaLEOmb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 09:42:31 -0500
In-Reply-To: <1417784633-13360-1-git-send-email-james.byrne@origamienergy.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/12/2014 14:03, James Byrne a =E9crit :
> The Kconfig file says that Gigabit mode is not supported, but it has =
been
> supported since commit 140b7552fdff04bbceeb842f0e04f0b4015fe97b ("net=
/macb:
> Add support for Gigabit Ethernet mode").
>=20
> Signed-off-by: James Byrne <james.byrne@origamienergy.com>

Yes indeed:
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

> ---
>  drivers/net/ethernet/cadence/Kconfig | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/cadence/Kconfig b/drivers/net/ether=
net/cadence/Kconfig
> index 9e089d2..6932be0 100644
> --- a/drivers/net/ethernet/cadence/Kconfig
> +++ b/drivers/net/ethernet/cadence/Kconfig
> @@ -35,8 +35,8 @@ config MACB
>  	---help---
>  	  The Cadence MACB ethernet interface is found on many Atmel AT32 a=
nd
>  	  AT91 parts.  This driver also supports the Cadence GEM (Gigabit
> -	  Ethernet MAC found in some ARM SoC devices).  Note: the Gigabit m=
ode
> -	  is not yet supported.  Say Y to include support for the MACB/GEM =
chip.
> +	  Ethernet MAC found in some ARM SoC devices).  Say Y to include
> +	  support for the MACB/GEM chip.
> =20
>  	  To compile this driver as a module, choose M here: the module
>  	  will be called macb.
>=20


--=20
Nicolas Ferre
