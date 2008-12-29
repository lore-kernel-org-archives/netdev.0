From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH] clean up of netif_rx_reschedule() changes in drivers
Date: Mon, 29 Dec 2008 21:41:44 +1100
Message-ID: <20081229214144.43be8c1d.sfr@canb.auug.org.au>
References: <20081229110041.0eca977a.sfr@canb.auug.org.au>
	<20081229102509.GA11111@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Mon__29_Dec_2008_21_41_44_+1100_Vy=lfNnRvOVlTdOm"
Cc: "David S. Miller" <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Linus <torvalds@linux-foundation.org>, netdev@vger.kernel.org,
	ppc-dev <linuxppc-dev@ozlabs.org>
To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20081229102509.GA11111@linux.vnet.ibm.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__29_Dec_2008_21_41_44_+1100_Vy=lfNnRvOVlTdOm
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Kamalesh,

On Mon, 29 Dec 2008 15:55:29 +0530 Kamalesh Babulal <kamalesh@linux.vnet.ib=
m.com> wrote:
>
> I hit similar build failure due to the change in the netif_rx_reschedule()
>=20
> drivers/net/ehea/ehea_main.c: In function 'ehea_poll':
> drivers/net/ehea/ehea_main.c:844: warning: passing argument 1 of 'netif_r=
x_reschedule' from incompatible pointer type
> drivers/net/ehea/ehea_main.c:844: error: too many arguments to function '=
netif_rx_reschedule'
> make[3]: *** [drivers/net/ehea/ehea_main.o] Error 1

Linus already took a patch for ibmveth and ehea.

> greping through the sources for the changes missed out, we have
>=20
	.
	.
>=20
> Signed-off-by: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
> --
>  drivers/net/arm/ep93xx_eth.c |    2 +-
>  drivers/net/arm/ixp4xx_eth.c |    2 +-
>  drivers/net/wan/ixp4xx_hss.c |    2 +-
>  3 files changed, 3 insertions(+), 3 deletions(-)

Thanks for the patch, I assume that Dave or Linus will take care of that.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Mon__29_Dec_2008_21_41_44_+1100_Vy=lfNnRvOVlTdOm
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAklYqWgACgkQjjKRsyhoI8yNdwCdFgntGytN5djrgItDgbErjx9S
YuEAn0SWGpiEYM8A0yZA9FnEHJn6mWBd
=B5Pg
-----END PGP SIGNATURE-----

--Signature=_Mon__29_Dec_2008_21_41_44_+1100_Vy=lfNnRvOVlTdOm--
