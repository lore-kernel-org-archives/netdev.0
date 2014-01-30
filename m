From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 1/4] net: ethoc: implement basic ethtool operations
Date: Thu, 30 Jan 2014 13:59:37 +0000
Message-ID: <1391090377.4405.58.camel@deadeye.wl.decadent.org.uk>
References: <1391025397-14965-1-git-send-email-jcmvbkbc@gmail.com>
	 <1391025397-14965-2-git-send-email-jcmvbkbc@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-2zox673OzisFMBe6uq5/"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Marc Gauthier <marc@cadence.com>
To: Max Filippov <jcmvbkbc@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391025397-14965-2-git-send-email-jcmvbkbc@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-2zox673OzisFMBe6uq5/
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-01-29 at 23:56 +0400, Max Filippov wrote:
> The following methods are implemented:
> - get link state (standard implementation);
> - get timestamping info (standard implementation).
>=20
> Signed-off-by: Max Filippov <jcmvbkbc@gmail.com>

Reviewed-by: Ben Hutchings <ben@decadent.org.uk>

> ---
>  drivers/net/ethernet/ethoc.c | 6 ++++++
>  1 file changed, 6 insertions(+)
>=20
> diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
> index 5854d41..6de6352 100644
> --- a/drivers/net/ethernet/ethoc.c
> +++ b/drivers/net/ethernet/ethoc.c
> @@ -900,6 +900,11 @@ out:
>  	return NETDEV_TX_OK;
>  }
> =20
> +const struct ethtool_ops ethoc_ethtool_ops =3D {
> +	.get_link =3D ethtool_op_get_link,
> +	.get_ts_info =3D ethtool_op_get_ts_info,
> +};
> +
>  static const struct net_device_ops ethoc_netdev_ops =3D {
>  	.ndo_open =3D ethoc_open,
>  	.ndo_stop =3D ethoc_stop,
> @@ -1148,6 +1153,7 @@ static int ethoc_probe(struct platform_device *pdev=
)
>  	netdev->netdev_ops =3D &ethoc_netdev_ops;
>  	netdev->watchdog_timeo =3D ETHOC_TIMEOUT;
>  	netdev->features |=3D 0;
> +	netdev->ethtool_ops =3D &ethoc_ethtool_ops;
> =20
>  	/* setup NAPI */
>  	netif_napi_add(netdev, &priv->napi, ethoc_poll, 64);

--=20
Ben Hutchings
It is a miracle that curiosity survives formal education. - Albert Einstein

--=-2zox673OzisFMBe6uq5/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIVAwUAUupayee/yOyVhhEJAQpDzg/9E9/H9g+LWQ2RycxGcL5XS7J3gadGaUJ3
jKGrF5d0fxg8GcMAgDxAdSzPQVv2W8eP8RFFhdP84fERW+GbgawFvd7UoV8jVEGP
tUi9ovX4Ce/s+4GHEoQf+qrQ+N+C1wN2xyWLL9hGoKspH7+zUb7Z/taGlnFoYBbj
Ey9Z+8RF2er8Ma9fdlxQqMCiu/9griiv07tnDRH+1eMnHb+AKklmWfEAWSMX2Dif
3K31D73BdQZDhcM4aFxDNc5eb8wcq6636P06ZUUTMnWEzfN+qbUOge3oWIpL96+y
WHQUx5+rlBLtbaw7VIo6aMMdWydb3FyczFGam/iYymonuHsvlmwYKKLHYUJxWMvq
4ES90/9BJE1G6Lnw2DY4zXGYU/HvnUXrPbwUoFwo6t4KNGW/bNjYq/O3KOHgOsz2
eGreIdJ6jvt9CULqq/sRA3YbkHObnyXjqxC7cj2NqJQPbzHLF59wSHf+JlhdvnpE
9+Ec9DvUIVMe76oGvrPxVyJke35BHpksJAt6f8BzFU6zCSeNGOl8EJbACEnmKHsu
iMLY/nDrn/E0llzCrHEGZcr5M9FerKG89Fz/XJDK2ltk5W9ijqBC8xXU9VMNGSIF
mNSuiq8zRYjUex/Ly84Wd06qwMaW5jLyzgGazMsCTphARNiIi2QZIRuXUEQNR4KH
mjPfFdA3hSY=
=5iuX
-----END PGP SIGNATURE-----

--=-2zox673OzisFMBe6uq5/--
