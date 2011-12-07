From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 1/2] e1000: unmap ce4100_gbe_mdio_base_virt in
 e1000_remove
Date: Wed, 07 Dec 2011 14:01:22 -0800
Message-ID: <1323295282.2415.36.camel@jtkirshe-mobl>
References: <1323276062-10906-1-git-send-email-ffainelli@freebox.fr>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-AL0dC619tTfmqT/UCab+"
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Florian Fainelli <ffainelli@freebox.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:35336 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751928Ab1LGWBY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Dec 2011 17:01:24 -0500
In-Reply-To: <1323276062-10906-1-git-send-email-ffainelli@freebox.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-AL0dC619tTfmqT/UCab+
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2011-12-07 at 08:41 -0800, Florian Fainelli wrote:
> We are not unmapping ce4100_gbe_mdio_base_virt in exit path in case
> we are running on a CE4100 adapter, fix that.
>=20
> Signed-off-by: Florian Fainelli <ffainelli@freebox.fr>
> ---
>  drivers/net/ethernet/intel/e1000/e1000_main.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)=20

Thanks Florian, I have added your two patches to my queue.

--=-AL0dC619tTfmqT/UCab+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJO3+IyAAoJEOVv75VaS+3OYU0P/1Bjxzm0VJFgHQ7qGL0ZMwRW
qm/lqucgaU24G/S1QmEPX/Q3RsHjbIarOHsg8bt4rw3MRVS0EXFEaU/mT0My3Uy0
QflCqEiAYgTbwLVKhXM+RxyvLQppTd0iSuUZG2TeJx4StiU+aeuPdQVoK6dFcQ6R
i9qKRU60ShXFTdQW4z108T2eWg0DbwxL2z0/UcPHFKCETCD9ZWBXFYxR5iEktgtF
eGZCvynjcl+k4ImuwlFu0CQKqTsA1UCMDoYudqhAo8ebavnzJfGeaAGZtEDJtBdN
pRfoMja4CuXFP5eJa7MypONyuG45qzo2+lZ62Z/z8kCKdJqeETcEnpTd71/N7HWk
RJ8w5BQyB8FL6vm0d1BMyFVWKcDdsSd8FUyG+IHinJbEJkDBQGvvXdud+/u3uXGL
gsg+LZw+HKbhTczl4PsNTHLMluLdOh7+LfrSt0VQ+kDYMwbbS/PdK8/2Qv8CAGOG
gCNixFAMf9DQxDkf0u6dgSuBIijiuP64BE9qRKyarWd1vzXKVNhm3Su9WKVhL5F0
PCpJD8KsfycSr0I0HamxXRRXB5J6ODoqDG2DPu0kmWYcIfLyL+rkZJu9OdRC3V2k
/GcfLXsAusSZuG0emosTD6F7FNFOPs71j2s0bsOAsyPB0bNZrZiKI7ObUnBZopL2
gBWJcQYQRe4zvBuNprhP
=5bSy
-----END PGP SIGNATURE-----

--=-AL0dC619tTfmqT/UCab+--
