From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] i40e: fix sparse warning
Date: Thu, 05 Feb 2015 17:52:47 -0800
Message-ID: <1423187567.2589.90.camel@jtkirshe-mobl>
References: <1423149195-32142-1-git-send-email-prabhakar.csengg@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-J6Z4Dl34yxPsIYbgbqYk"
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Matthew Vick <matthew.vick@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Linux NICS <linux.nics@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Lad Prabhakar <prabhakar.csengg@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423149195-32142-1-git-send-email-prabhakar.csengg@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-J6Z4Dl34yxPsIYbgbqYk
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2015-02-05 at 15:13 +0000, Lad Prabhakar wrote:
> From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>
>=20
> this patch fixes following sparse warning:
>=20
> i40e_lan_hmc.c:911:24: warning: constant 0xFFFFFFFFFFFFFFFF is so big
> it is unsigned long
>=20
> Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>
> ---
>  Found this issue on linux-next (gcc  version 4.8.2,
>  sparse version  0.4.5-rc1)and applies on top linux-next.
>=20
>  drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

I already have a fix in my queue to resolve this issue, so I am dropping
your patch.

--=-J6Z4Dl34yxPsIYbgbqYk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJU1B5vAAoJEOVv75VaS+3OCyQQAItNEOETSD2OQ43IV8raMerS
yP9WtAOdVBRPrm+g+0WCbDnp2z8jX3r2xNShZYCS48/xr3H5Ay197m7C9TFbhleG
+cyqy+4p6X052nIGKTCGNLo9GVRlpAKR1JXbkSKDNS90lTywMKmdh622J9oCNQMw
moqMSKtDi79nqmaGBT3NsfdOQOPNJG6TUmtYr+4rjN9MNle0No0GhcFvyQ3HtHBX
fRYb2JquXF7quQ+ti+Q9iK2lS6qlrXeh5T2k/BEHsJ/z0M+GttEQ/KWljozMx9ES
elOOBjh1maFt0IM3ktrRfZXAG4u3ZO7COpaL2P9v9LRW7a4+zeW2rbdiRWlitV6E
JjjaBMrYizzL3UCo/TbTHKhzbzxMcpqoxlK/H0t+vsTnpmrQALFJVKJ/SVaK6Lt6
60XWDUPqFTBY8PNu9SJ5vyJeS5i0xONxGvxR4TqeWR3I27SQK6m7GyA4deyz7XEG
ucIQ3atJ4dOz1klzJDJonAC+FsU2KfPpnO2zODmZwHdmanrm1ji14AX8QTvg3VH8
fMi/u4iGRIDyuxPxaJ/1h78Urigooqp+Qr4wQrtgL+0qMOksTJ+ts5A0npzYfJLP
2x3vB6J/whw0CiiZR8uh4wGcEWEnyGsWRvONgdgdSrWORHD2m9JGWGwY+brR50dM
HbSiWhMvRiDtcPWpn0U9
=Abuh
-----END PGP SIGNATURE-----

--=-J6Z4Dl34yxPsIYbgbqYk--
