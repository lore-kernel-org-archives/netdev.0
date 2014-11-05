From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net 2/5] i40e: Implement ndo_gso_check()
Date: Wed, 05 Nov 2014 04:35:03 -0800
Message-ID: <1415190903.2420.56.camel@jtkirshe-mobl>
References: <1415138202-1197-1-git-send-email-joestringer@nicira.com>
	 <1415138202-1197-3-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-B7f7YwCzYtF3L7+3EQe2"
Cc: netdev@vger.kernel.org, sathya.perla@emulex.com,
	linux.nics@intel.com, amirv@mellanox.com, shahed.shaikh@qlogic.com,
	Dept-GELinuxNICDev@qlogic.com, therbert@google.com,
	linux-kernel@vger.kernel.org
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415138202-1197-3-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-B7f7YwCzYtF3L7+3EQe2
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-11-04 at 13:56 -0800, Joe Stringer wrote:
> ndo_gso_check() was recently introduced to allow NICs to report the
> offloading support that they have on a per-skb basis. Add an
> implementation for this driver which checks for tunnel headers over
> UDP
> of up to 64 octets in length.
>=20
> Implementation shamelessly stolen from Tom Herbert:
> http://thread.gmane.org/gmane.linux.network/332428/focus=3D333111
>=20
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_main.c |   14 +++++++++++++-
>  1 file changed, 13 insertions(+), 1 deletion(-)

Thanks again Joe, I will add your patch to my queue.

--=-B7f7YwCzYtF3L7+3EQe2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUWhl3AAoJEOVv75VaS+3OWywP/1f57qcQ3R6mOdigPWWEU46O
ykDNC8MlnOCrACQGuaDzq5PJLnWRJtEHyPrOuSsStfdeGGvSydCbymwG0dY/ttx1
ufb+oWs/OdpWCKBs0hMz25oGEnTO++SfaFZmMe5hpduhch+6Mo6z0IE7adGdwTzj
SOnCclcToPKztbGpxP3DAU//hBomBAzYdL8uFPz5TrqTW0AgcnXQEBbWicw0zglw
KMTkfhZd3D4jr8KsRJp0glll4gJ0PiSGdYtIYK+9svPYMrb4ffnkwK5PxyMZtDIq
wAdklrGc84UDeqhRlnP9yBGy9lJ7X6nQ1Rfu73iTYAQQ6DqnIjWOe6chzsdsGnJg
wLmQOCy/34JOGmlRhtKzMNVmMFEHS+4WvuwjgL0pdGcdBvyrKVEpGyl+8C0zSnFn
eTeAs+MVFDZdG2Zh6PRfxSS/tXfpTf9+CJum/W+klEMyo+THJNn93ytVfoWoerRr
J4J7j2mK4DDCaV9vw3sAS4Qr/ntvgEALAIIoiAEFoDsPbgRjxwbnisamEMr7BODf
EfqkxQ9XA6VPYdkT7rTyit9hhBZxME0o3d6LCpvXeiZtl0qu9fEHsFH31yDoqSvf
OJ/SgMqJfi8eOnldgIZSu0Gvhkv0pHXHukNeNvHKry7nGQs45OeMeeVBpW/r5wba
6QablT55NpfmsTuR0Cp/
=pD6x
-----END PGP SIGNATURE-----

--=-B7f7YwCzYtF3L7+3EQe2--
