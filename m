From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next v1 01/18] net: ethtool: propagate get_settings
 error
Date: Wed, 28 Jan 2015 16:30:30 +0000
Message-ID: <1422462630.2709.23.camel@decadent.org.uk>
References: <1422322574-6188-1-git-send-email-ddecotig@gmail.com>
	 <1422322574-6188-2-git-send-email-ddecotig@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-+UcI3RAOAqXFNkoXi8f6"
Cc: "David S. Miller" <davem@davemloft.net>,
	Amir Vadai <amirv@mellanox.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-api@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Eugenia Emantayev <eugenia@mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Joe Perches <joe@perches.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Govindarajulu Varadarajan <_govind@gmx.com>,
	Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Eyal Perry <eyalpe@mellanox.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Ed Swierk <eswierk@skyportsystems.com>,
	David Decotigny <decot@googlers.com>
To: David Decotigny <ddecotig@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422322574-6188-2-git-send-email-ddecotig@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-+UcI3RAOAqXFNkoXi8f6
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2015-01-26 at 17:35 -0800, David Decotigny wrote:
> From: David Decotigny <decot@googlers.com>
>=20
> Signed-off-by: David Decotigny <decot@googlers.com>
> ---
>  net/core/ethtool.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index 91f74f3..52efb7e 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -364,7 +364,7 @@ static int ethtool_get_settings(struct net_device *de=
v, void __user *useraddr)
> =20
>  	if (copy_to_user(useraddr, &cmd, sizeof(cmd)))
>  		return -EFAULT;
> -	return 0;
> +	return err;

err cannnot be negative at this point (and if it's positive, that's a
bug in the get_settings implementation which we happen to fix up).

Ben.

>  }
> =20
>  static int ethtool_set_settings(struct net_device *dev, void __user *use=
raddr)

--=20
Ben Hutchings
Teamwork is essential - it allows you to blame someone else.

--=-+UcI3RAOAqXFNkoXi8f6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVMkOq+e/yOyVhhEJAQqV5Q/9HQltpXHuRfZqtnbHPvWQGD/zxSl4x4NS
rFWrVYBlr9wdb250PSLuum7ixYWYS46BC6ON00yMV3IaU4Y5J48Y+comJEV7DnQ8
rq0B9D1uJI1v6kQbgPzovU6i1E8RdZUI24JEBbN2hALuHwNznXj3ouoM06RPg5z1
NZGNg40ucuk9r8IQAjk2UuNPJeHo+7NvOVeT0VeAvcQHGZwJdjxRgpITnbJ/6zOB
hkxYzuRo7k1su4D2IDvsHo0OiufUna9pQVmEY5CI7/yfNq1JUZ7mN/TvZhxncwUY
HS5jchcurqrnsUI80nNyq5k6QEC0A067HdrfMiVi9J12OynpOKd6gKHXqggWUnlc
F7bxpsLGILuORekUyFYWNWgJxXJfMwtK0VsirEKjsswx/y5X2eFHlKCmXcojybVV
gHsX3JWhLGirwPobEuwgivFtd0IjkjJdsLQjBrtD6+D2EZZ/sZJ1AOflZdPDBHgA
akfERt+BQV2VpeG+6PCKNd4gWX+9e8cbUg/8K46Km5i0cOrGaW2yl4JMEZdf7gtf
hTS5qFx+rzwka0NaTXxm2lxXly6jHpTzfTGjtv+dP608W5NX6j/WsBLKKOpWvdNp
KiL5gLatujtfl87cBdeqtODWDPXsA2FlDnWlFATtF6CXaJarJn/nWkks5ddqqaik
nGpp836Ye1U=
=IaPK
-----END PGP SIGNATURE-----

--=-+UcI3RAOAqXFNkoXi8f6--
