From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: Re: [patch 1/3] net/islpci_dev: replace schedule_timeout() with msleep()
Date: Mon, 7 Mar 2005 12:13:04 -0500
Message-ID: <20050307171304.GR3936@ruslug.rutgers.edu>
References: <20050306222352.514491EC90@trashy.coderock.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Er/3qITiDpnrteFh"
Cc: prism54-private@prism54.org, netdev@oss.sgi.com, nacc@us.ibm.com,
        janitor@sternwelten.at
To: domen@coderock.org
Content-Disposition: inline
In-Reply-To: <20050306222352.514491EC90@trashy.coderock.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Er/3qITiDpnrteFh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


Patch applied to prism54 latest svn tree, thanks

	Luis

On Sun, Mar 06, 2005 at 11:23:51PM +0100, domen@coderock.org wrote:
>=20
>=20
>=20
>=20
> Use msleep() instead of schedule_timeout()
> to guarantee the task delays as expected. Also set_current_state() is
> inserted before schedule_timeout().
>=20
> Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> Signed-off-by: Maximilian Attems <janitor@sternwelten.at>
> Signed-off-by: Domen Puncer <domen@coderock.org>
> ---
>=20
>=20
>  kj-domen/drivers/net/wireless/prism54/islpci_dev.c |    3 +--
>  1 files changed, 1 insertion(+), 2 deletions(-)
>=20
> diff -puN drivers/net/wireless/prism54/islpci_dev.c~msleep-drivers_net_wi=
reless_prism54_islpci_dev drivers/net/wireless/prism54/islpci_dev.c
> --- kj/drivers/net/wireless/prism54/islpci_dev.c~msleep-drivers_net_wirel=
ess_prism54_islpci_dev	2005-03-05 16:09:30.000000000 +0100
> +++ kj-domen/drivers/net/wireless/prism54/islpci_dev.c	2005-03-05 16:09:3=
0.000000000 +0100
> @@ -438,8 +438,7 @@ prism54_bring_down(islpci_private *priv)
>  	wmb();
> =20
>  	/* wait a while for the device to reset */
> -	set_current_state(TASK_UNINTERRUPTIBLE);
> -	schedule_timeout(50*HZ/1000);
> +	msleep(50);
> =20
>  	return 0;
>  }
> _

--=20
GnuPG Key fingerprint =3D 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E

--Er/3qITiDpnrteFh
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFCLIufat1JN+IKUl4RAtQdAJ9bY5y7NUYwF7bVjmoQXndTSZTNnwCglaEk
HBspnFcPstZax4SPtHZtg0I=
=nGuK
-----END PGP SIGNATURE-----

--Er/3qITiDpnrteFh--
