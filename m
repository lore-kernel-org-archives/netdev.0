From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH ethtool 1/5] ethtool-copy.h: sync with net
Date: Tue, 14 Apr 2015 15:58:41 +0100
Message-ID: <1429023521.3211.49.camel@decadent.org.uk>
References: <1422193883-30504-1-git-send-email-amirv@mellanox.com>
	 <1422193883-30504-2-git-send-email-amirv@mellanox.com>
	 <1428195613.11260.111.camel@decadent.org.uk>
	 <CAPcc5Pj7Xo0ETPzpqgjnf9tA9AeNnqOFPiPFE7XXFYSinXRsXA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-C9WLY/8utRXOrgUfnVib"
Cc: netdev <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>,
	Eyal Grossman <eyalgr@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:44167 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753763AbbDNO6y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 10:58:54 -0400
In-Reply-To: <CAPcc5Pj7Xo0ETPzpqgjnf9tA9AeNnqOFPiPFE7XXFYSinXRsXA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-C9WLY/8utRXOrgUfnVib
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2015-04-14 at 17:34 +0300, Amir Vadai wrote:
> On Sun, Apr 5, 2015 at 4:00 AM, Ben Hutchings <ben@decadent.org.uk> wrote=
:
> > On Sun, 2015-01-25 at 15:51 +0200, Amir Vadai wrote:
> >> From: Eyal Grossman <eyalgr@mellanox.com>
>=20
> [...]
>=20
> >
> > You've copied from include/uapi/linux/ethtool.h, which is not quite
> > right.  The include/uapi directory contains definitions shared with
> > userland, but the headers still need some processing (like removing the
> > _UAPI prefix from header guards).  You should use 'make headers_install=
'
> > to generate the userland version in usr/include/linux/ethtool.h.
> Sorry, didn't know.
>=20
> > Anyway, I've done that myself based on today's net tree.
> Is it in your git [1] ? Because I couldn't find the updated version there=
.
>=20
> [1] - git://git.kernel.org/pub/scm/network/ethtool/ethtool.git

Sorry, it is now.

Ben.

--=20
Ben Hutchings
Editing code like this is akin to sticking plasters on the bleeding stump
of a severed limb. - me, 29 June 1999

--=-C9WLY/8utRXOrgUfnVib
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVS0rJue/yOyVhhEJAQqVCBAAg5/1+SurUE0TuxqmlQjd3I+FOQdkBVhA
boRpfcdPPb0Z1DQPisjuti/W5rTFYzhdvmOBd65kRKnsVMNfEKb0iWhBHPPrmhXy
gSRQcRydhlVpQcEpIfiKGfbtUK2sW4cgpxsEDoA8ak5D4wMv6mRgsDtnGWfg+xGl
HENkbh+ezs3w1an2EmGjQG7XVSaky8jq+kofa9PzjCtODVmEExMCd/Nw8Azjy+tn
PCYGfcyQwOru8RsmAJTK91mMtpHx4xr/6dN4nnzcpHCJ+WxVk/qF/eFwkZaGdWmC
1JzIhxVmyIOfH7+00J9225T+Bcwm5qSLgOTeun0PdTElqZD1mSCvc0NEZ4hlEwEe
g3oyyWVefCMhHfXjdc3fQIgF9lhi6w5ILEeS/3r2ni8AMsIq6V3qxNrfa9gpCjfJ
aamxHeprOMn4z3cXjRxVoR7mZ8XAG0i/iZWOd8VAr2sAUxeQUXYXZNbxd0ekNMsr
Cs7OcCuYVBIXsiZ4c1+Ea9//AvEKrMZ3rgg/p0s9rrlbZEpnYOxylkwWxqJTokXS
pWxGV1b0duhhvx0iHp7rqKbHLy9I4iyXRygtdr6LI5vQt/mNrOOOWIK5233PnCT5
uUpSbJUUiaCwTWgFw6AVXZtpr/FYFpX5wh9Z3mGBlkiLMj4A1tmLG/ABIu7jgGzc
54NYayYPzWs=
=URjO
-----END PGP SIGNATURE-----

--=-C9WLY/8utRXOrgUfnVib--
