From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCHv2 net] i40e: Implement ndo_gso_check()
Date: Thu, 20 Nov 2014 15:14:07 -0800
Message-ID: <1416525247.2280.11.camel@jtkirshe-mobl>
References: <1416525081-27779-1-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-6iZJ3TkcRoqhUIQhY9Ez"
Cc: netdev@vger.kernel.org, shannon.nelson@intel.com,
	jesse.brandeburg@intel.com, therbert@google.com,
	linux.nics@intel.com, linux-kernel@vger.kernel.org,
	jesse@nicira.com
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1416525081-27779-1-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-6iZJ3TkcRoqhUIQhY9Ez
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-11-20 at 15:11 -0800, Joe Stringer wrote:
> ndo_gso_check() was recently introduced to allow NICs to report the
> offloading support that they have on a per-skb basis. Add an
> implementation for this driver which checks for IPIP, GRE, UDP
> tunnels.
>=20
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> ---
> v2: Expand to include IP in IP and IPv4/IPv6 inside GRE/UDP tunnels.
>     Add MAX_INNER_LENGTH (as 80).
> ---
>  drivers/net/ethernet/intel/i40e/i40e_main.c |   31
> +++++++++++++++++++++++++++
>  1 file changed, 31 insertions(+)

If Jesse is good with the updated patch, I will add it to my queue.
Thanks Joe!

--=-6iZJ3TkcRoqhUIQhY9Ez
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUbnW/AAoJEOVv75VaS+3OEPkP/3b+YzHaa4/pMJjD5msUbXq9
H+6N5VmkZG4ZmJtcwk5iAk4oDYSHFOx6/uGQclwYh6yA6mVqd41ZkhL1vdylwgyd
48Hy6WoF1EXEIsuGAjE0mMGgJFM1iBQLK27H+ryIwe8f+qFvxycnAvtZH5nyas59
DZT727XMlLRKCRMrqdUIDh3Eg7V60/8rN+74Bb1TYvvERgGQX70i5PYpj5YxxAyw
eTNgNmaxASvK6btLF1Tvv+EyUz3m8Yuse5BNzr8Gza111usbUEGH5GfHutii9PJk
t02Kf/0wuPMxP4/6CPQS4oFqoI/MPQ0y3fPqLhoB2stTvclMe8DzE8pFATT5TlMR
JLFLpKB5E529taE4P8XVS5jhddBtORW/I1p2+vXaxGyG1S6ekFTHLzKIdE6+bhqb
s2dt2cKc3PeJ+ULEl6Vdfl37d9Qb7dF2FzDFdJWdRZ0qls5JWSQww8Em7a/o3I9K
zV5+cttrLqNuyFjJzWsEjjI+3ex7nGLhRBE/ptWDpNd8p7/nAuRdq/KVdd8VmLf4
bCZSKQEt7SUBP4kDjJwDqeVuzrDGzLgDACj4xfmgbLWRu2ERTT9TjUgqu7nsBros
C6lF2nQkQZtbTuPcyFKf8OOU+7NuoTz+zwGNGqJTEcKr2HswsxlPTv/ehc66j69H
F9udWlE7iW9tEPh8gseD
=HSTr
-----END PGP SIGNATURE-----

--=-6iZJ3TkcRoqhUIQhY9Ez--
