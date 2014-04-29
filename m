From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [net-next] vxlan: Advertise SCTP checksum offloads
Date: Tue, 29 Apr 2014 13:39:21 +0100
Message-ID: <1398775161.3881.9.camel@deadeye.wl.decadent.org.uk>
References: <1398714735-23920-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-2txT2ybL6mxw4Aw9tB5Y"
Cc: davem@davemloft.net, Greg Rose <gregory.v.rose@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:49445 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933248AbaD2Mj3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2014 08:39:29 -0400
In-Reply-To: <1398714735-23920-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-2txT2ybL6mxw4Aw9tB5Y
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-04-28 at 12:52 -0700, Jeff Kirsher wrote:
> From: Greg Rose <gregory.v.rose@intel.com>
>=20
> Some HW can offload encapsulated SCTP checksums.  Advertise the capabilit=
y
> for such cases.

Don't we need a software fallback on the output path before doing this?

Ben.

> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Acked-by: Joseph Gasparakis <joseph.gasparakis@intel.com>
> Acked-by: Shannon Nelson <shannon.nelson@intel.com>
> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/vxlan.c | 1 +
>  1 file changed, 1 insertion(+)
>=20
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 1dfee9a..988208f 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -2293,6 +2293,7 @@ static void vxlan_setup(struct net_device *dev)
>  	dev->features	|=3D NETIF_F_SG | NETIF_F_HW_CSUM;
>  	dev->features   |=3D NETIF_F_RXCSUM;
>  	dev->features   |=3D NETIF_F_GSO_SOFTWARE;
> +	dev->features   |=3D NETIF_F_SCTP_CSUM;
> =20
>  	dev->vlan_features =3D dev->features;
>  	dev->features |=3D NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_STAG_TX;

--=20
Ben Hutchings
Q.  Which is the greater problem in the world today, ignorance or apathy?
A.  I don't know and I couldn't care less.

--=-2txT2ybL6mxw4Aw9tB5Y
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUAU1+deue/yOyVhhEJAQp7HQ//TSU/Q949aEorH2iBWHTIl3rOzR7dC8+0
IBFBBQPZNRuxOnZXuRMlmYescIm8r3VmE1rGU1dp2uqS04L3gwj9lYwXtveg0H4S
fwDzsLWJYcEJMPP0QfvTn9p4dFBWTsLVImhR/x/PTt6N69BX6d04cK2q67h+X5m8
fuxCe3U0+w5uAhytlszymOQPAtZIxkBS0J9nJi1IP8LFgO6mLVYlGG7Hx8TQKpO/
M1HsqSK3W4V7nDDk74LYu6kDbNLij80LAHTBoObJxphEpnkuaiQrd7JYGJGaHAIN
vv18KO8bImGJ+NJ6VaL8NPvkKUht2QKPAlqZYUr+gJfpgiM3dGjRI9UfcQPSkqWG
fsbKOOPU7Ue3G07RlxqMFWRiL+3ZWOh5zkC96Q7g2spJ2u7G4AYXEPl9kpRml0CU
As2zEA8DnV5UbTBzVZIDp7bbiU8BNm3M4YDru7MCCKP5kE/z+iE0qJ+4OBkk/mbQ
sPwjlItuh7UL62JrKDd4ZGmx1nQw2McJHVbqxfyEutadvS0+ocI7aXur0F/xpXBE
NkCy0mk+wf39EqZrTbuh8ulsuU0rlvkCfM0sxUE0S7xX9kLFIeaG4O8VxkVbKYQX
UcO37sbCkstbJcozJDmuwYd8oqiuum+CuG/AMl6pGoQZEjSQRUl+crjrLZ1TfgSG
48qnyW10AOw=
=Eeu7
-----END PGP SIGNATURE-----

--=-2txT2ybL6mxw4Aw9tB5Y--
