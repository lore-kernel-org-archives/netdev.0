From: Luotao Fu <l.fu@pengutronix.de>
Subject: Re: [Socketcan-users] [PATCH] CAN: make checking in can_rcv less
 restrictive
Date: Fri, 7 Aug 2009 13:46:25 +0200
Message-ID: <20090807114625.GA6838@pengutronix.de>
References: <1249572295-7801-1-git-send-email-l.fu@pengutronix.de>
 <4A7B0957.5020808@hartkopp.net>
 <200908070952.56922.remi.denis-courmont@nokia.com>
 <4A7C117E.5010005@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="45Z9DzgjV8m4Oswq"
Cc: R?mi Denis-Courmont <remi.denis-courmont@nokia.com>,
	Luotao Fu <l.fu@pengutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"socketcan-users@lists.berlios.de" <socketcan-users@lists.berlios.de>,
	Michael Olbrich <m.olbrich@pengutronix.de>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:41269 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751925AbZHGLq0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 07:46:26 -0400
Content-Disposition: inline
In-Reply-To: <4A7C117E.5010005@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--45Z9DzgjV8m4Oswq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Oliver,

On Fri, Aug 07, 2009 at 01:35:26PM +0200, Oliver Hartkopp wrote:
> R?mi Denis-Courmont wrote:
=2E...
>=20
> @Luotao: I talked to Urs and we discussed to prepare a patch that only cr=
eates
> a warning and drops the skb afterwards, as the problem is not critical fo=
r a
> proper ongoing kernel operation. I think, that was you original intention:
>=20
>        if (!net_eq(dev_net(dev), &init_net) ||
>            WARN_ON(dev->type !=3D ARPHRD_CAN) ||
>            WARN_ON(skb->len !=3D sizeof(struct can_frame) || cf->can_dlc =
> 8)) {
>                kfree_skb(skb);
>                return NET_RX_BAD;
>        }
>=20
> Would this be ok for you?

I'm absolutely fine with this.

thx
cheers
Fu
--=20
Pengutronix e.K.                           | Dipl.-Ing. Luotao Fu        |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |

--45Z9DzgjV8m4Oswq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkp8FBEACgkQiruQY+UyUmGUYACfSALUfEhT/SA2PI/qE5LUf3ky
/yMAoKqJ+Q+qXnZ9Tl0tXNkZz83gbu2i
=mffO
-----END PGP SIGNATURE-----

--45Z9DzgjV8m4Oswq--
