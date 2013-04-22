From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net] e1000e: fix numeric overflow in phc settime method.
Date: Mon, 22 Apr 2013 10:53:22 -0700
Message-ID: <1366653202.2037.2.camel@jtkirshe-mobl>
References: <1455e8dd5f574fef93377b61cea8b494102091ef.1366638698.git.richardcochran@gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-WdUmUz+iNeCf7iIvBzfv"
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Jeroen Van den Keybus <jeroen.vandenkeybus@triphase.com>,
	bruce.w.allan@intel.com, e1000-devel@lists.sourceforge.net
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:20279 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754109Ab3DVRxY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Apr 2013 13:53:24 -0400
In-Reply-To: <1455e8dd5f574fef93377b61cea8b494102091ef.1366638698.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-WdUmUz+iNeCf7iIvBzfv
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2013-04-22 at 15:53 +0200, Richard Cochran wrote:
>=20
> The PTP Hardware Clock settime function in the e1000e driver
> computes nanoseconds from a struct timespec. The code converts the
> seconds field .tv_sec by multiplying it with NSEC_PER_SEC. However,
> both operands are of type long, resulting in an unintended overflow.
> The patch fixes the issue by using the helper function from time.h.
>=20
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>
> ---
>  drivers/net/ethernet/intel/e1000e/ptp.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)=20

Thanks Richard, I will add this to my queue.

--=-WdUmUz+iNeCf7iIvBzfv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJRdXkSAAoJEOVv75VaS+3OXMYQAI682+5AXRY5vWMtHGKUqorZ
xLFMYEl4XKDs76vlM5y/jfBkg3YeVqXcln5JTCcZJHxj6MjdgB6qn76PPNprvoVB
iDdHgvuIw8c4ua15PYhBTttBBEIBU2kDU1L/I7PaFUr1QufmxMM8qDf7LqDbZpBY
l6E6hk/CEkwsNsBIpZK1y7gblyuVUkmMf052FWPs+MIZ9OKezoe8zCYK+CHE1/Oq
EqKqA7JuJ0ZuwK2QbH/ykt5ubrYkYPryrwYfpWGoNXQLOvKWtfEXIcn5ElzfAG8M
XYf6gIyixqcJ8cV+WmhWwGAkVfJ+mv/n56msH022UPt09V61vlMPXLxaJZVFLHYC
WuEP2jJEjNYcYIFii61Uwq4JoR52ibHzTN0TZU4b1jx4SWpPCv1J1mFFbknaN6yc
tLWPXzI6ZvxsOa8SKe24iQNeZ2ILjxuKW2OGXjPdiKk8Rg6Evxb6up2HFnlJxwYb
Hf3cme4yyh7PKI1ZjKhmt855U8zK7rC0CVV/92hPQ5SZeWdinXYh9d8uKVuLV5os
9EpHjtVBx090U+72NMngf5NEo8mVp7cj+PNULkH9Wb/vVpsnlLhCwBO4i/KcgzSR
YP5HfjZtTZdIGvNxY/1wgvGNWJkHp3ilRtfOij1F5lbW7zIU2P6Ig79kO5xxIHN+
nrn7vl9P07xjDcPzz18a
=Pn9J
-----END PGP SIGNATURE-----

--=-WdUmUz+iNeCf7iIvBzfv--
