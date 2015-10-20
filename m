From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] fm10k:Fix error handling in the function fm10k_setup_tc
Date: Tue, 20 Oct 2015 16:06:13 -0700
Message-ID: <1445382373.2937.10.camel@intel.com>
References: <1445375114-13378-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-UtLDRubAlvsRn6nATLDb"
Cc: jesse.brandeburg@intel.com, shannon.nelson@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	matthew.vick@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:32337 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753043AbbJTXGc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Oct 2015 19:06:32 -0400
In-Reply-To: <1445375114-13378-1-git-send-email-xerofoify@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-UtLDRubAlvsRn6nATLDb
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2015-10-20 at 17:05 -0400, Nicholas Krause wrote:
> This fixes error handling in the function fm10k_setup_tc to properly
> check if the call to the function fm10k_open has failed by returning
> a error and if so return immediately to the caller of the function
> fm10k_setup_tc to properly signal this non recoverable failure.
>=20
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
>  drivers/net/ethernet/intel/fm10k/fm10k_netdev.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)

Is this a version 2 of your original patch you sent out with the same
title and patch description?  It is difficult to understand the reason
for the change without a sufficient changelog (i.e. why the new version
of the patch).
--=-UtLDRubAlvsRn6nATLDb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJWJsjlAAoJEOVv75VaS+3OOnUP/0cbvgLuyyPezWWM/4b7eIEq
FPt8KM8sYy0s7Rt4DEPGxxM3kOoz1TsHe7kxzScywM8gQ/Dcz8DHqPTKGB5XxyIZ
j9ZazywfzCfGL8plwJfAZY46NUqG+6P7rj8QPWxptUuUxbwDQ35Ofs8g0mIh2LOQ
usdAh9CVwIXGlDq6LktNNAhb3UysmERuzDiu+qsP+gLTAlFUgJR/bpJA+6Pjv5S8
oCyM1z8I4+YmdpcOG7Dlw9WrbZcJ5BIpcN0PujXS2yQ+n5YVqX+QbwZO0ityS9ni
WIekhO6ncSKbw7Gmk22J1HffTPXK6Qiz+kjVbIe0AenaotPom4KVRMOYyYZKA7nS
4hDSuIkOuhHX1OHEs8vHKX8VKzC6GHvhE2aCE+igyyHtBieOB9L5Y+RV4m2vFyH5
2oYCoEadOh2FSioEQh3NtGs1PKM+K8fP6CHe4AhO48jX44Q/jWuxoOUJmCcZ5U2P
NiNRd5bSPpwRS9ev4wJe8hVCRcZUN0z8jzyZbBAtJlHKzez8l57m95c7jg3INbmi
Lx5XbhO52dCKTpfH/O4LIsOUx+3NBNSGQQIB8qDQ9Iyn68vKtWmsoB/SRb6GPNy8
eiGI4nDPkGGU9jXGHlvM/UlqlNCTSqee1LN0vZYI+6/tTF3LXvUmBU9jir27S6oi
ucQ/unPB0gYzk2lA65yp
=bGfc
-----END PGP SIGNATURE-----

--=-UtLDRubAlvsRn6nATLDb--
