From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH net v2 6/7] net: cpmac: fix proper spacing before return
 statement
Date: Thu, 10 Jul 2014 08:09:03 -0500
Message-ID: <20140710130903.GF15340@saruman.home>
References: <1404970545-26508-1-git-send-email-varkabhadram@gmail.com>
 <1404970545-26508-7-git-send-email-varkabhadram@gmail.com>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="SxgehGEc6vB0cZwN"
Cc: <netdev@vger.kernel.org>, <mugunthanvnm@ti.com>,
	<linux@rainbow-software.org>, <balbi@ti.com>,
	<george.cherian@ti.com>, <davem@davemloft.net>,
	Varka Bhadram <varkab@cdac.in>
To: <varkabhadram@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:42711 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753644AbaGJNKC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jul 2014 09:10:02 -0400
Content-Disposition: inline
In-Reply-To: <1404970545-26508-7-git-send-email-varkabhadram@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--SxgehGEc6vB0cZwN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jul 10, 2014 at 11:05:44AM +0530, varkabhadram@gmail.com wrote:
> From: Varka Bhadram <varkab@cdac.in>
>=20
> This patch insert proper spaces before return statement.
>=20
> Signed-off-by: Varka Bhadram <varkab@cdac.in>

can probably be merged with previous patch:

Reviewed-by: Felipe Balbi <balbi@ti.com>

> ---
>  drivers/net/ethernet/ti/cpmac.c |    8 ++++++++
>  1 file changed, 8 insertions(+)
>=20
> diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cp=
mac.c
> index 3d3ead4..b6efe3e 100644
> --- a/drivers/net/ethernet/ti/cpmac.c
> +++ b/drivers/net/ethernet/ti/cpmac.c
> @@ -283,6 +283,7 @@ static int cpmac_mdio_read(struct mii_bus *bus, int p=
hy_id, int reg)
>  		    MDIO_PHY(phy_id));
>  	while ((val =3D cpmac_read(bus->priv, CPMAC_MDIO_ACCESS(0))) & MDIO_BUS=
Y)
>  		cpu_relax();
> +
>  	return MDIO_DATA(val);
>  }
> =20
> @@ -293,6 +294,7 @@ static int cpmac_mdio_write(struct mii_bus *bus, int =
phy_id,
>  		cpu_relax();
>  	cpmac_write(bus->priv, CPMAC_MDIO_ACCESS(0), MDIO_BUSY | MDIO_WRITE |
>  		    MDIO_REG(reg) | MDIO_PHY(phy_id) | MDIO_DATA(val));
> +
>  	return 0;
>  }
> =20
> @@ -308,6 +310,7 @@ static int cpmac_mdio_reset(struct mii_bus *bus)
>  	ar7_device_reset(AR7_RESET_BIT_MDIO);
>  	cpmac_write(bus->priv, CPMAC_MDIO_CONTROL, MDIOC_ENABLE |
>  		    MDIOC_CLKDIV(clk_get_rate(cpmac_clk) / 2200000 - 1));
> +
>  	return 0;
>  }
> =20
> @@ -537,6 +540,7 @@ fatal_error:
>  	cpmac_hw_stop(priv->dev);
>  	if (!schedule_work(&priv->reset_work))
>  		atomic_dec(&priv->reset_pending);
> +
>  	return 0;
> =20
>  }
> @@ -883,6 +887,7 @@ static int cpmac_set_ringparam(struct net_device *dev,
>  	if (netif_running(dev))
>  		return -EBUSY;
>  	priv->ring_size =3D ring->rx_pending;
> +
>  	return 0;
>  }
> =20
> @@ -1076,6 +1081,7 @@ static int cpmac_stop(struct net_device *dev)
>  	dma_free_coherent(&dev->dev, sizeof(struct cpmac_desc) *
>  			  (CPMAC_QUEUES + priv->ring_size),
>  			  priv->desc_ring, priv->dma_ring);
> +
>  	return 0;
>  }
> =20
> @@ -1178,6 +1184,7 @@ static int cpmac_probe(struct platform_device *pdev)
>  			 "mac: %pM\n", (void *)mem->start, dev->irq,
>  			 priv->phy_name, dev->dev_addr);
>  	}
> +
>  	return 0;
> =20
>  fail:
> @@ -1191,6 +1198,7 @@ static int cpmac_remove(struct platform_device *pde=
v)
> =20
>  	unregister_netdev(dev);
>  	free_netdev(dev);
> +
>  	return 0;
>  }
> =20
> --=20
> 1.7.9.5
>=20

--=20
balbi

--SxgehGEc6vB0cZwN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTvpBvAAoJEIaOsuA1yqREzWMP/RfNh5nzKvHRmCsjPF9AG2fl
oFdmxjBuRblihKnC7fD4rB/Gsf7Ly6Hn0zsY5ZTJs8DploFatEKfVV/iIoSolqzH
6yBOYVBfYwdSw/VW0kBErIQGaGvRqGj4LL/LBI1Oukc5axBeqDTyUtvbOT35UqW1
B1vzH2OVdngNC9ZrthF3dDyDSGFKo0anr65Xpccl0UlyIpRt3CbvEJcf5TYztzbW
pVoJ5l7YPGrsyIGkGeOMyzAh8HX4W1CxHCf+IcovRunGxErQxk2VV2rTS+yQsnh9
ptyg852pzHlpNynj8vb+cBLJ1yLpuRtpVan/mLo2VaMXtr5FXh4AzYDJ63qXohfE
/fDUHHwaOtcAEQWzBKwo8KN/epe5SDhzJvd4l4hELkZJ30B4hf6bMcBwct4+k0kL
s5emkMSg8feFk5BEL+amnfAkhmmI+rCjHn2AbJlKo1go0ilKeS4oiEdU9dWxYAzv
+PuznIpeLik8Zq3vWH9mRN5XInJRDtvRNvw+FNb04A1d+sm/lxQOJLtA5sMXttRg
PLAn+1O2mRD4FXQs5UVzeGlROhiM6B/cRd25kiG3RlL0HZOaAasI7Q2FspBYrX48
jG7e6rt/tULl6h35pQVjpGrYwuS4DG67ya0g42a7PVWMWflKdiPPc5gMDgd0F02M
EngcpSgwG8Fb0ubZ6ec0
=9p44
-----END PGP SIGNATURE-----

--SxgehGEc6vB0cZwN--
