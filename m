From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: config NET_ETHERNET
Date: Wed, 09 Nov 2011 01:28:18 -0800
Message-ID: <1320830898.2493.20.camel@jtkirshe-mobl>
References: <1320799275.14409.437.camel@x61.thuisdomein>
	 <20111109.001540.816179448716894786.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-HJsVHvlPpEfKB0r0vZ9K"
Cc: "pebolle@tiscali.nl" <pebolle@tiscali.nl>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:45707 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754168Ab1KIJ2T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Nov 2011 04:28:19 -0500
In-Reply-To: <20111109.001540.816179448716894786.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-HJsVHvlPpEfKB0r0vZ9K
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2011-11-08 at 21:15 -0800, David Miller wrote:
> From: Paul Bolle <pebolle@tiscali.nl>
> Date: Wed, 09 Nov 2011 01:41:15 +0100
>=20
> > 0) The Kconfig symbol NET_ETHERNET got dropped in commit f860b0522f
> > ("drivers/net: Kconfig and Makefile cleanup").
> >=20
> > 1) However, there are still a number of references to that symbol
> and to
> > the macro CONFIG_NET_ETHERNET:
> >     $ git grep -n "NET_ETHERNET\>"  | grep -v defconfig:
> >     arch/cris/arch-v10/drivers/Kconfig:6:     select NET_ETHERNET
> >     arch/cris/arch-v32/drivers/Kconfig:6:     select NET_ETHERNET
> >     drivers/s390/net/Kconfig:7:       depends on CCW && NETDEVICES
> && (NET_ETHERNET || TR || FDDI)
> >     drivers/s390/net/lcs.c:53:#if !defined(CONFIG_NET_ETHERNET) && \
> >     drivers/s390/net/lcs.c:1637:#ifdef CONFIG_NET_ETHERNET
> >     drivers/s390/net/lcs.c:2169:#ifdef CONFIG_NET_ETHERNET
> >=20
> > 2) It's trivial to draft a patch which drops both that Kconfig
> symbol
> > and the macro (and everything that could be considered dead code by
> > now). But perhaps this needs a more sophisticated solution.
>=20
> The best thing to do for now is to switch these references over
> to use just plain "ETHERNET" and that's what I'll commit into
> the net tree.
>=20
> --------------------
> [PATCH] net: Fix references to deleted NET_ETHERNET Kconfig setting.
>=20
> Change them over to plain "ETHERNET"
>=20
> Reported-by: Paul Bolle <pebolle@tiscali.nl>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  arch/cris/arch-v10/drivers/Kconfig |    2 +-
>  arch/cris/arch-v32/drivers/Kconfig |    2 +-
>  drivers/s390/net/Kconfig           |    2 +-
>  drivers/s390/net/lcs.c             |    6 +++---
>  4 files changed, 6 insertions(+), 6 deletions(-)=20

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

--=-HJsVHvlPpEfKB0r0vZ9K
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJOukeyAAoJEOVv75VaS+3OmpMP/2KXGgGqx1udjugbnsXC/f0J
Q0bogDsqb8lAYO0t7+eywAdPkqWsuQYWHnVuxX3tudvdXuxS6ok5TqTljPQMQNQJ
uHNEPXkWPeqhwf+d9shCzMsYLGQarR68EZgtZv75+eVzJCUvoV99W59iSgNYUVpc
oJDLHKFawLJ2bf+IqeS94Ys3CKh9BTEoBa9sTkiYUOVKlSklQlKzX06wYDDffBy9
cvlOKRXkAwNq/A2zHlPWEE9Ah01KeiBQYawk1J9sqhaDdBIsOZST6voPk8BRIuo0
Hx7kOw9KpiljAv54lnAUhbUTLB2caXuY6EMKlXUWUYs5h4cKWv7+u68TBh8D64cr
uVW/hhi+oQe+khLFK0dO+5FBv8mMBbRpp9kIf6/IUK0/UFm9EA/W3hcskg1WVYIO
VTpdDY1kTaUw/Jz/zaX2FP/H94RlniVbs6O+V3HHTQ34k0A4y5+U8nE2Y582V7AO
zdSxRXJa9dPZNnX/eOzhg2Pd0EmeGpvzsyi54aa+jHkp65ACZoAf4KEEA49SDSfl
hVxZ8dUukJwTPFL4MKJU740ytVpdGQVG1mGziYqWmfC3kNtvniCe6XFWAPxtJLyG
t70sQKuObvVVaDmeRountUDJGiESiH77u0VOz53IwrmBKwN0fyp61DJbCsEwHto7
Nisk7ya/3wg/W3oTLS1P
=wtYb
-----END PGP SIGNATURE-----

--=-HJsVHvlPpEfKB0r0vZ9K--
