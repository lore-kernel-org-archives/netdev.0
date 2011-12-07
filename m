From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v2] e1000e: Assign true and false to bool type variable
 instead of 1 and 0
Date: Wed, 07 Dec 2011 01:04:24 -0800
Message-ID: <1323248664.2415.28.camel@jtkirshe-mobl>
References: <4EDED071.40900@linux.vnet.ibm.com>
	 <1323229439.2415.23.camel@jtkirshe-mobl>
	 <1323231268.1762.19.camel@joe2Laptop> <4EDEF05F.4020901@linux.vnet.ibm.com>
	 <1323237700.1762.24.camel@joe2Laptop> <4EDF02CC.4010407@linux.vnet.ibm.com>
	 <1323238749.1762.27.camel@joe2Laptop> <4EDF0964.3080509@linux.vnet.ibm.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Fk48C76roeukqdzlXl5w"
Cc: Joe Perches <joe@perches.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"wangyunlinux@gmail.com" <wangyunlinux@gmail.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Michael Wang <wangyun@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:57019 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751777Ab1LGJFC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Dec 2011 04:05:02 -0500
In-Reply-To: <4EDF0964.3080509@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Fk48C76roeukqdzlXl5w
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2011-12-06 at 22:36 -0800, Michael Wang wrote:
> On 12/07/2011 02:19 PM, Joe Perches wrote:
>=20
> > On Wed, 2011-12-07 at 14:08 +0800, Michael Wang wrote:
> >> I'm not good at script, if you are interested, we can work together
> to
> >> fix all the remain cases, and send out some patches.
> >=20
> > You should try coccinelle and spatch.
> >=20
>=20
> Hi, Joe
>=20
> I have not used coccinelle and spatch before, I will study on them
> later.
>=20
> > If you run the script, this is the intel output.
> >=20
> >  drivers/net/ethernet/intel/e1000/e1000_main.c |   10 +++++-----
> >  drivers/net/ethernet/intel/ixgb/ixgb_main.c   |    2 +-
> >  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    2 +-
> >  drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c  |    4 ++--
> >  4 files changed, 9 insertions(+), 9 deletions(-)
>=20
>=20
> We can try to fix them, thanks for the suggestion.
>=20
> Regards,
> Michael Wang=20

So should I expect a v3 of this patch?

Also I am fine with lumping all the changes for all our drivers in one
patch as long as the changes for each driver are somewhat small.  If the
changes for a particular driver gets too extensive, please create a
separate patch.

Cheers,
Jeff

--=-Fk48C76roeukqdzlXl5w
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJO3ywYAAoJEOVv75VaS+3OGE8P/R/Z3fup/W/ZCSMrY47SwFVJ
4O3shq9TrD4z6A5SCDz4CxwDS6sTc7KW7Qc6z5TH8hAG47A/DJKGFiHa99WVfxaL
iGdvfZ5XT5lnDOZyeCpH5KTCKrQofIB9qcBRlBzhoKegbrU9gPq+iCve4fwpPs3W
32MDaISQ2BleqGDcDjYVHrZodPbiqC6jlZOtYsqJ4wXcOjqXqb4Pgn4N+rvkPd9l
97zNr0NYViycFdJC19nPZKuJuetM2kHtmXXU7GyCvDvwbjFGERckVmyAF563XuGJ
uwRRrn67dDQaWQh8DnJZzApy1cXvxgfQ+Mvz9eneNEL0/ActKK6JTmnz4GytvXYo
BlNqwR4YTQ9uEYMHrUOkNqI3L/sLcJeZo96qH2JOWzojPgftsz+hehcN5ubydyD4
EnD/1MJ9Z8eyvHEii5aIbyhqLQ+IFtlpOi5zhC+PtZMZ6BiTlrLfzx7XWibqkjc1
lmU7dE9HjfkS7sxiVwZDarcj3fwh3hSlYByfuAijft6PRkEXT2n68TSPJb4UR2KC
4JqFhwY5cF9pXS2DG8bt9z++7KTsZ+uS1uTfC62YMbTxnF8wV0XUfgziQ1w4e8lQ
iUhTy+4Pjd7C0v043qKIO/AF1gtaF/3l/9rd+PhyP2x1/MPtQ+NrrWBNQCiaj9Uo
0wgPFiW0AnihUaGNvcpk
=hRx7
-----END PGP SIGNATURE-----

--=-Fk48C76roeukqdzlXl5w--
