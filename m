From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] net: refactor multicast/unicast address list
Date: Tue, 16 Jun 2009 13:29:31 +0200
Message-ID: <1245151771.9256.3.camel@johannes.local>
References: <1244889678.13033.6.camel@johannes.local>
	 <1244896094.13033.8.camel@johannes.local>
	 <20090616111842.GG3521@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-uuTipJeHENiwQU3rUNFz"
Cc: Netdev <netdev@vger.kernel.org>
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:43649 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750979AbZFPLaD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 07:30:03 -0400
In-Reply-To: <20090616111842.GG3521@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-uuTipJeHENiwQU3rUNFz
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2009-06-16 at 13:18 +0200, Jiri Pirko wrote:
> Sat, Jun 13, 2009 at 02:28:14PM CEST, johannes@sipsolutions.net wrote:
> >On Sat, 2009-06-13 at 12:41 +0200, Johannes Berg wrote:
> >> I'm trying to use address lists without netdevs, but as
> >> a first step I thought it would be good to reduce the
> >> amount duplicated code between unicast and multicast
> >> lists.
> >>=20
> >> After introducing a new 'struct address_list', we can
> >> unify a lot between these. The next step will probably
> >> be exporting the __dev_addr_sync and __dev_addr_unsync
> >> functions so I can use them without a netdev, but this
> >> cleanup can stand on its own.
> >
> >Sorry, this was based against the wrong tree and now I see that in
> >net-next the lists have diverged significantly. Ignore this.
>=20
> Yes, I've already converted unicast lists to use list_head there. I'm sen=
ding
> the patch doing the same for multicast lists soon.

Very nice! After that maybe I'll take a look again at moving things into
a common structure -- I ultimately want to use a multicast list without
a netdev to sync multiple netdevs onto a common multicast list that is
not part of a netdev.

johannes

--=-uuTipJeHENiwQU3rUNFz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKN4IXAAoJEODzc/N7+QmaKgYQAMvCk6hwKcA8kBaW1lifYYyQ
rGchjfAZRcrUAVhWtLK0ZcsIFTDEyGoAGZTgQe+HUwca5+pXY2HQaLxv1ngphGAr
zYKjLjnXVpWR3DDFkbPyl6bwiSuD0KhT+iFav/gsHAjeSUXxURJcm9OKQZCiKXb4
Yv8wfdXYWTj5jBAbMDPeEu5/t+HbKgwf4ww2neHBC1A657BxDEU1vN8ePzYVk/SU
XzmYJ/HXTjHO31EIrVR4lxh5aFCLEadpbc8sbUfOnw7Gc1F6UKaC08KTicWDkHlO
zdExDusLr6/CIdFqpUUd0kw0+gJExedOUEvavXLqiZqaIllvxQ7kCP92V6c+PTh4
ZbUkkmn06Sn/p3/MVrdPDJhRLZhQ7wjgeERWDAY2GLiYRnxMvO97mbO/7hL6v54f
14qlNZg7WHXoxRX11CRN/Dbn7ZcQuV0qE1XX63G0XVnBoI5ONP2FfrPWlIWa7N2L
gyDrtUbzu+qytCzw69maCfkIzDiRSBQh9li0SW4sbmrchUn1vyLZmmYCo3lwwm6V
uhbGUgBAL3rXQAJkAaaKrh5163vfnADipEqOd00929vLsP35dbsIru6PM1K7pRSI
mOmnvi4RXrIDCKv2BAzzzDzgNuNH/WU/8Vq6BJLlGcg2nusCML2qK+uK3dZk7Iye
+RnYusFn5H9qqKNpt9Mi
=/O3f
-----END PGP SIGNATURE-----

--=-uuTipJeHENiwQU3rUNFz--

