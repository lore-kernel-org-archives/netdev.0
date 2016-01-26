From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 1/3] i40e: fix build warning
Date: Mon, 25 Jan 2016 16:01:43 -0800
Message-ID: <1453766503.2932.13.camel@intel.com>
References: <1453702251-464-1-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-9wnR8JnbcmE2cJdF2IOg"
Cc: linux-kernel@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org
To: Sudip Mukherjee <sudipm.mukherjee@gmail.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453702251-464-1-git-send-email-sudipm.mukherjee@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-9wnR8JnbcmE2cJdF2IOg
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2016-01-25 at 11:40 +0530, Sudip Mukherjee wrote:
> While building we are getting warning about:
> i40e_main.c:8604:13: warning: 'i40e_add_geneve_port' defined but not
> used
> and
> i40e_main.c:8651:13: warning: 'i40e_del_geneve_port' defined but not
> used
>=20
> The contents of these functions are defined under CONFIG_GENEVE, so
> if
> CONFIG_GENEVE is not defined then we are having unused empty
> functions.
> Lets have these functions under CONFIG_GENEVE as the callback is
> already
> defined under CONFIG_GENEVE there is no chance of any failure.
>=20
> Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
> ---
> =C2=A0drivers/net/ethernet/intel/i40e/i40e_main.c | 6 ++----
> =C2=A01 file changed, 2 insertions(+), 4 deletions(-)

This is not a complete fix for the issue and Eric Dumazet has already
submitted a fix for the issue, which I have just sent to David Miller
in a pull-request.

So I have dropped this patch, in favor of Eric's solution.
--=-9wnR8JnbcmE2cJdF2IOg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJWprdnAAoJEOVv75VaS+3OA+4P/0lUOQ9EGk9/M2qVIu8SIsaS
UBMHalnL+3iI0yqC0MkI8Om7wGHoJJeIlU+lwWaUBU8KaONM01znJTgG3zzQ7a4Q
LrKTySLiBSYFHArbRzoTH3cZYoLBzdUhnuQMp9jrLOZtQsSYHLyNBBzvEE7ueT7F
1eJuWDRaTnAxQUHC+hXYBwA81HlCmfU8xQPKQWOK35qOlHDQMGe3SQXdgrdd7jpw
W5l4C8WFUD+G3J8OvmtyBp2DAMbEQthoW9hj6vZIsw45aQQ+3uIUbcKiCaYSBRY7
JQZujo6hAPkOieZ7+CzUDlR5/GUhn+TsyaEQiIKmnIW0R9Lpg92VApvUlk/Ovs/a
Q+tzhEWCTpj4cVFv/HlIhvQ7K0PJUmfmx2OPJ9GcwdcMocmCxloaHUVbv3zyipis
KJtWJxEdHWGKSKMHrJvgf4fvaBzNj6rS3pizyqrTTX75g32S7uHy0ACvcpoq8coX
MlIp5uIk0ObA6vF/fOg51ZV/LQPhMVkVe4DcMVfEhFDBBEzVCvM7by4fiRn9rt0Y
dg+jIIH/1wDiozk0BUDxrpz9eEAq2BKpd+j9bmI8hYXjKOrwaP1hwPkIkNOdQ1/D
rLFCuyJ8J1fNhri1l5uXQZZdOlj5SDEY4H10gNH1/hTPA/VXwz3DLbkvrYFjKe3p
f7QpWhAgicUc6G0E+3Uw
=b4Lh
-----END PGP SIGNATURE-----

--=-9wnR8JnbcmE2cJdF2IOg--
