From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v5 04/19] net: e100: Replace PCI pool old API
Date: Wed, 08 Mar 2017 14:40:25 -0800
Message-ID: <1489012825.3477.51.camel@intel.com>
References: <20170308161957.28941-1-romain.perier@collabora.com>
         <20170308161957.28941-5-romain.perier@collabora.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
        protocol="application/pgp-signature"; boundary="=-p87cXMN0K7D4rRhQU6Ip"
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org, linux-scsi@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Peter Senna Tschudin <peter.senna@collabora.co.uk>
To: Romain Perier <romain.perier@collabora.com>,
        Dan Williams <dan.j.williams@intel.com>,
        Doug Ledford <dledford@redhat.com>,
        Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        "David S. Miller" <davem@davemloft.net>, stas.yakovlev@gmail.com,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        Felipe Balbi <balbi@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170308161957.28941-5-romain.perier@collabora.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-p87cXMN0K7D4rRhQU6Ip
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2017-03-08 at 17:19 +0100, Romain Perier wrote:
> The PCI pool API is deprecated. This commit replaces the PCI pool old
> API by the appropriate function with the DMA pool API.
>=20
> Signed-off-by: Romain Perier <romain.perier@collabora.com>
> Acked-by: Peter Senna Tschudin <peter.senna@collabora.com>
> Tested-by: Peter Senna Tschudin <peter.senna@collabora.com>
> ---
> =C2=A0drivers/net/ethernet/intel/e100.c | 12 ++++++------
> =C2=A01 file changed, 6 insertions(+), 6 deletions(-)

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

My only concern is:
- what hardware did this get tested with?  Since this affects all e100
parts, it would be hard to believe that all the affected hardware was
used in testing.
--=-p87cXMN0K7D4rRhQU6Ip
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiTyZWz+nnTrOJ1LZ5W/vlVpL7c4FAljAiFkACgkQ5W/vlVpL
7c5KqA//dfxwhSSaEHsZcSVBClb6RNEyuAtgW6MYWhTdnRHDEDd253nmWumlU6he
UYpJMs8FMKTYU1VFJ1fN3hzxN3t+jls9I39DMgtEcWv0LFGfQScJt2W8qh8IeheK
dIlXtzM2JWM3XKWjASPTjY0S3o/cZrxuJo5Yv/2t6/Y/18nghdmXs9qtZo5ewBih
A67A73qd7AvEpa4VPoCF6QI0yez+sIIi8Lmo9th34P61UyZU1HyUwijO/j3uGA0+
cXjLs3weVzH0CJQlRO0KSOTigl7I7QjOawpM8e8QW3x0eGO5pBOZjhGMwux70+Zd
K6lZHIZoyua9qRCEiKpQw/MXaquzoTL8l7ctNqOFloWe63rxgwsnDO8QmfXURBSs
DiY9uJEYoXvyuQloxpiA/lZm/drH5vAGMQG2equMcqT9IAN3yTWs3/NG4MQMcPoz
9Nym9qOPXOKc7W9YLhK5JbQjyt7HvosEF2WN+quWPR0WY5e2YGqcXiPGqwUH0YkS
KRuxTmKcNMkqICUYXKZpk2ACdkoVCH02yqRunBYUtsFgD9BFx4JXBhJ4HLWRzZTW
kw8dlUG+eyVo+0UCJoB9S2L63yIgTsHnnQQIy99hDslRiUygSZUkO15UgjLko2dc
+APGhTqnm5BzG52lOIYaUzfyGElUzJByzWP2O4H6RuzfAin68B4=
=+lcU
-----END PGP SIGNATURE-----

--=-p87cXMN0K7D4rRhQU6Ip--
