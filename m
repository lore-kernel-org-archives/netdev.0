From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: oops with recent wireless-dev tree
Date: Thu, 30 Aug 2007 14:05:30 +0200
Message-ID: <1188475530.2963.20.camel@johannes.berg>
References: <20070829223752.GA6969@seehuhn.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-k++eE6lgayPUMaShUuKJ"
Cc: linux wireless list <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
To: Jochen Voss <voss-52ZyvxujusuELgA04lAiVw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070829223752.GA6969-52ZyvxujusuELgA04lAiVw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-k++eE6lgayPUMaShUuKJ
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hi Jochen,

[added CCs since it affects bridge code]

> If I read this correctly, the EIP in the last line corresponds to
> net/bridge/br_if.c, line 36:
>=20
>     static int port_cost(struct net_device *dev)
>     {
> 	    if (dev->ethtool_ops->get_settings) {
>                                ^^^^
>=20
> As far as I can figure out, dev->ethtool_ops is NULL and the crash
> happens while trying to derefernce ...->get_settings.
>=20
> Is dev->ethtool_ops allowed to be NULL?  In this case the appended
> patch might be the correct fix.  At least it makes the oops disappear
> for me.  Another possible fix would be to add an ethtool_ops structure
> to the device created by b43.

I don't think adding ethtool_ops in mac80211 should be necessary.
Stephen?

johannes

--=-k++eE6lgayPUMaShUuKJ
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBG1rKK/ETPhpq3jKURAidxAJ43uGOXdW8H7E9VH+Kft4Ix4At+0QCeOtju
Q4/RpDfYQGtbeINda8xd0ic=
=NaRp
-----END PGP SIGNATURE-----

--=-k++eE6lgayPUMaShUuKJ--
