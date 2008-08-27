From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] atl1e: multistatement if missing braces
Date: Wed, 27 Aug 2008 05:37:24 -0400
Message-ID: <48B52054.1000204@garzik.org>
References: <Pine.LNX.4.64.0808191029460.4551@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jie Yang <jie.yang@atheros.com>, Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59094 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754009AbYH0Jhe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 05:37:34 -0400
In-Reply-To: <Pine.LNX.4.64.0808191029460.4551@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen wrote:
> Doesn't cause problems (yet) because err gets zeroed earlier.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
> ---
>  drivers/net/atl1e/atl1e_main.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
>=20
> diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e=
_main.c
> index 82d7be1..7685b99 100644
> --- a/drivers/net/atl1e/atl1e_main.c
> +++ b/drivers/net/atl1e/atl1e_main.c
> @@ -2232,10 +2232,11 @@ static int atl1e_resume(struct pci_dev *pdev)
> =20
>  	AT_WRITE_REG(&adapter->hw, REG_WOL_CTRL, 0);
> =20
> -	if (netif_running(netdev))
> +	if (netif_running(netdev)) {
>  		err =3D atl1e_request_irq(adapter);
>  		if (err)
>  			return err;
> +	}

applied


