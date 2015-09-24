From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net PATCH 1/3] i40e: Fix handling of napi budget
Date: Wed, 23 Sep 2015 21:54:53 -0700
Message-ID: <1443070493.2987.0.camel@intel.com>
References: <20150922213002.2774.37924.stgit@ahduyck-vm-fedora22>
	 <20150922213529.2774.42390.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-bgX6vEw7XvhK1P8DubqR"
To: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:22141 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750995AbbIXEzU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Sep 2015 00:55:20 -0400
In-Reply-To: <20150922213529.2774.42390.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-bgX6vEw7XvhK1P8DubqR
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2015-09-22 at 14:35 -0700, Alexander Duyck wrote:
> The polling routine for i40e was rounding up the budget for Rx
> cleanup to
> 1.  This is incorrect as netpoll will call is expecting no Rx to be
> processed as the budget passed was 0.
>=20
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_txrx.c |    5 +++++
>  1 file changed, 5 insertions(+)

This does not apply cleanly to my next-queue tree, dev-queue branch.
--=-bgX6vEw7XvhK1P8DubqR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJWA4IdAAoJEOVv75VaS+3OrI8P/03/Di8FUbLMyzjrjksXtedZ
U/L5fvTT7DjweTnX2xfgBPVyHhUby4K3Ek3M/LAgn/sXjlrNWVo9oNdS8rhmIA80
Rb9M6opf1Zyqe+BsI8w9DDVFdA931R+Qzk28+AgubXOMbRGtDUuWGrllIJXdzkVL
0/pPnfaDFWfAhK1LryGdpMPPtpADjD/+XgURC/EueA/N3krmv0V4gtgqhxykoYWh
gYa2OE/QNBUrj4MZZVIGJhOOEEFwtznJ+N1f7+T63Bw9NduiWleUUVkZe63ajjPL
sAAZuNcCKVK3yrxcdhUQfgFIhGIiBqknMj2tkGVGc7R7rjFTlHLZgI8rCgxRWmjl
p8lJG6amh83EIWIeZ++jye+iE0Wg/QZNp1G2AGp0Q5YXGlDknnQDZ3rMhXsEkVJN
JY3ZuQdBjnCDanAv/YE5KbilM5SE8lZH0WQkMpFiYSBzzCCkn9ZuK8ziL2nlKSBd
Uq4wam50dXoCYhvzxR77XOHf3HK8HR9iJ/9WzwpxtSNruUIFfKPKbABt8JzFS7XL
7GFRJnlpBf0fZrk6nZCeKUMMqcYyDzwd2X+LQLd127ByAE9doJBxEMk7+e3CGZpp
jXHZBU9MCQdfrNuxO80thO3Aq3gfSFJCmfSROxGX7kpUJ5oBYPR8DC2+FnMpeP/5
4GX/DRErijNmKIOH7LZP
=rkmD
-----END PGP SIGNATURE-----

--=-bgX6vEw7XvhK1P8DubqR--
