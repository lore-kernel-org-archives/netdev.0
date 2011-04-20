From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH] staging: octeon-ethernet: remove .get_sg, etc.
 ethtool_ops
Date: Wed, 20 Apr 2011 07:36:12 -0700
Message-ID: <20110420143612.GA22661@suse.de>
References: <20110420142553.D497813909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:34261 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751875Ab1DTOlM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2011 10:41:12 -0400
Content-Disposition: inline
In-Reply-To: <20110420142553.D497813909@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 20, 2011 at 04:25:53PM +0200, Micha=C5=82 Miros=C5=82aw wro=
te:
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> ---
>  drivers/staging/octeon/ethernet-mdio.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/staging/octeon/ethernet-mdio.c b/drivers/staging=
/octeon/ethernet-mdio.c
> index 10a82ef..8a11ffc 100644
> --- a/drivers/staging/octeon/ethernet-mdio.c
> +++ b/drivers/staging/octeon/ethernet-mdio.c
> @@ -91,8 +91,6 @@ const struct ethtool_ops cvm_oct_ethtool_ops =3D {
>  	.set_settings =3D cvm_oct_set_settings,
>  	.nway_reset =3D cvm_oct_nway_reset,
>  	.get_link =3D ethtool_op_get_link,
> -	.get_sg =3D ethtool_op_get_sg,
> -	.get_tx_csum =3D ethtool_op_get_tx_csum,
>  };

Why are you doing this?  Please explain it better in the changelog and
resend this.

thanks,

greg k-h
