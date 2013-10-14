From: Aaro Koskinen <aaro.koskinen@iki.fi>
Subject: Re: [PATCHv2] staging: octeon-ethernet: trivial: Avoid OOPS if
 phydev is not set
Date: Mon, 14 Oct 2013 22:06:10 +0300
Message-ID: <20131014190610.GC4260@blackmetal.musicnaut.iki.fi>
References: <1381773535.2049.4.camel@alpha.Speedport_W723_V_Typ_A_1_00_098>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "driverdev-devel@linuxdriverproject.org"
	<driverdev-devel@linuxdriverproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	dan.carpenter@oracle.com
To: Sebastian =?iso-8859-1?Q?P=F6hn?= <sebastian.poehn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from filtteri5.pp.htv.fi ([213.243.153.188]:58830 "EHLO
	filtteri5.pp.htv.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756057Ab3JNTGT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Oct 2013 15:06:19 -0400
Content-Disposition: inline
In-Reply-To: <1381773535.2049.4.camel@alpha.Speedport_W723_V_Typ_A_1_00_098>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 14, 2013 at 07:58:55PM +0200, Sebastian P=F6hn wrote:
> Sorry. Haven't signed off for a while now :(
>=20
> I bet that this is really an issue of incorrect OF information. If I =
find out more I'll let you know.
>=20
> @dan: The code works for some interfaces - so phydev is set correctly=
 in some cases.

Kernel git log is not a chat forum; please write a proper changelog,
if possible include the original oops log.

Thanks,

A.

> Signed-off-by: Sebastian Poehn <sebastian.poehn@googlemail.com>
> ---
> diff --git a/drivers/staging/octeon/ethernet-mdio.c b/drivers/staging=
/octeon/ethernet-mdio.c
> index 83b1030..bc8c503 100644
> --- a/drivers/staging/octeon/ethernet-mdio.c
> +++ b/drivers/staging/octeon/ethernet-mdio.c
> @@ -121,6 +121,9 @@ static void cvm_oct_adjust_link(struct net_device=
 *dev)
>  	struct octeon_ethernet *priv =3D netdev_priv(dev);
>  	cvmx_helper_link_info_t link_info;
> =20
> +	if (!priv->phydev)
> +		return;
> +
>  	if (priv->last_link !=3D priv->phydev->link) {
>  		priv->last_link =3D priv->phydev->link;
>  		link_info.u64 =3D 0;
>=20
> _______________________________________________
> devel mailing list
> devel@linuxdriverproject.org
> http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-de=
vel
