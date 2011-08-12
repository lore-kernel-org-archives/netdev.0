From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next] spider_net: fix compile issue introduced by driver
 move
Date: Thu, 11 Aug 2011 20:40:14 -0700
Message-ID: <1313120415.2029.3.camel@jtkirshe-mobl>
References: <1313120000-12085-1-git-send-email-jeffrey.t.kirsher@intel.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-kEHJf8VPfCEOo4TDO6cj"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1313120000-12085-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-kEHJf8VPfCEOo4TDO6cj
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2011-08-11 at 20:33 -0700, Kirsher, Jeffrey T wrote:
> Both Spider net driver and Sun GEM driver use the sungem_phy.o object.
> This fix creates a Kconfig object for sungem_phy (like MDIO) so that
> both drivers require the SUNGEM_PHY object.
>=20
> This has been compile tested for the Sun GEM driver.
>=20
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/Kconfig               |    4 ++++
>  drivers/net/Makefile              |    2 +-
>  drivers/net/ethernet/sun/Kconfig  |    1 +
>  drivers/net/ethernet/sun/Makefile |    3 ++-
>  4 files changed, 8 insertions(+), 2 deletions(-)=20

Stephen, is it possible for you to try this patch to ensure it resolves
the compile issue you saw for the Spider Net driver when merging with
David's net-next tree?

--=-kEHJf8VPfCEOo4TDO6cj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJORKCeAAoJECTsCADr/EWUMOkH/2XsQbtXmnGqA4uIjo7HswJF
khMegDmKUDhb9+MbQl8Od8N5lzJco3vudql4HnMvK1QRQdc1+uFpu/TfTNdIS13x
0RozZgzRCHiVlOUeq/b5GlS3Tz5G3hCXaxpPvs0qYA4wMBAeQrkzkdY3mg8U6TQN
57QhY2X71i2SyyiN6cPXBErx8O6BoaG077Xq4ZDDX0M7tSvZpQq2QCRO/65X0omC
UD/6omxMA/ZRhTqboWWKOO+E28syozkifXC68JLNdZW6FwajTPoR+uMbOogRYdbl
KbvEwyBDoLpZZJism1LiXVbahxXauzmzB6A+34PUB1ar3qkf+AuXM5CIhIfIhbc=
=+NVq
-----END PGP SIGNATURE-----

--=-kEHJf8VPfCEOo4TDO6cj--
