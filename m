From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] ethernet: fm10k: Actually drop 4 bits
Date: Thu, 22 Jan 2015 19:27:52 -0800
Message-ID: <1421983672.2560.41.camel@jtkirshe-mobl>
References: <1421967198-16667-1-git-send-email-linux@rasmusvillemoes.dk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-cB5feE4NS2SCmVETGgyc"
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:14928 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751911AbbAWD15 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2015 22:27:57 -0500
In-Reply-To: <1421967198-16667-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-cB5feE4NS2SCmVETGgyc
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2015-01-22 at 23:53 +0100, Rasmus Villemoes wrote:
> The comment explains the intention, but vid has type u16. Before the
> inner shift, it is promoted to int, which has plenty of space for all
> vid's bits, so nothing is dropped. Use a simple mask instead.
>=20
> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
> ---
>  drivers/net/ethernet/intel/fm10k/fm10k_pf.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Thanks Rasmus, I will add your patch to my queue.

--=-cB5feE4NS2SCmVETGgyc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUwb+4AAoJEOVv75VaS+3OIfIP/RcuhentUqJMrWPbjO7VNq68
LyyzZNWEjRg2/WL3u/ppz9Yh7DEFXsJYe7u8uGN5gclN5y4u+Yh079oJ1+lWyzeT
BguQnpArvbvLREDymuE95NIj1+A0n4sI2J10MRMfNLSN0JHwgx9+qzqDgpXLP9bd
ZiS+xWc+ewSucth+ujyWc30XLEcZutGTg8dBjNllW8eyBDN16FUUQk0zx5wrXMCc
juT2f21yD3Jgo16vtE0JcxzbLDapOjn9XF/AhaDCGqxhz3V79qXMfuZE0faK6y4A
TH6j9eNFSHC9CKGxImr96+Cic9pjjRZr8vkX9LfimkGXzy+H6HTZOKGwQNsVcB7c
dHbR3nwGqXiImWAgpmCS48PW+L7NHvg0fo+ak2YYNwgOV3j1FVDz1/fOTnXypFZ9
fAbh3k6WIdOEh2H7nKf+siihVa+vunR98CArj6JpPS5Upa/vey7rD6bvnBJRKUmf
mMC/d0MjdQzmvQCMFLdzHkfqiPSxDwp/M3so0P977tsvvZuxGn6L2BpGqhSMfOqa
tYdhJENjHpGdPvIGDN1/SPRwhPt+rCymAEhJqYLdd1qqwtr/l3m4cPXn0SwlWUsA
gybM3Nzq8Rh4WjIzzeYtbE5KlCGDmeT7EPANE8k63tHvJloJ1rG0WN7jjU7MvH9C
5VIrSXc8LoXaqeRP0d/w
=WGrr
-----END PGP SIGNATURE-----

--=-cB5feE4NS2SCmVETGgyc--
