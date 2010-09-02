From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-2.6] 3c59x: Remove incorrect locking; correct
 documented lock hierarchy
Date: Thu, 02 Sep 2010 01:42:58 +0100
Message-ID: <1283388178.5323.300.camel@localhost>
References: <20100901.143815.215547115.davem@davemloft.net>
	 <1283377631.5323.285.camel@localhost> <1283378907.5323.287.camel@localhost>
	 <20100901.173736.190380817.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-JMBfETpio6Ih2NlygJHe"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:59614 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752178Ab0IBAnN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 20:43:13 -0400
In-Reply-To: <20100901.173736.190380817.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-JMBfETpio6Ih2NlygJHe
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2010-09-01 at 17:37 -0700, David Miller wrote:
> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Wed, 01 Sep 2010 23:08:27 +0100
>=20
> > I think this is safe after all because ethtool and MII ioctls are all
> > serialised by the RTNL.
>=20
> Well since you said that there was a regression that you're unable
> to reproduce, I was trying to find a probably cause for it :-)
>=20
> I think you should work to resolve that report, and resend this
> locking patch once that is sorted out.

That regression seems to due to my *earlier* changes to locking.  This
new patch fixes a different regression I found while trying to reproduce
that, and it has not been applied in Debian yet.  Sorry for the
ambiguous wording.

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-JMBfETpio6Ih2NlygJHe
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUATH7zCOe/yOyVhhEJAQJy6BAApIJS2IgGna9zzeiN4SywSefeqmS8xxVS
EScQ5NoUXKxjMcm/HdCEg5mAY+MbwdsHNK9YaYP9Lly5mUEe38Hk6PW9PFulv2b0
nmZ/wHZtf1S6BY8OckHym/6MDr6Hd8nv+sL45FzswZylrCtJ3qOjsi85xctt1jHH
/7d2or4D2Sr88LgiXEmZIpt6Q9hsM7IZspiKDLgDg+8s5OBpUP1EYcuFCxL+m911
Z4TXjOdTZ2kY7Jt996lPKwQ2PJ4T0uW1tq07wab44clepvHWfQ5qyNTU3ERCJTTu
ORzCdKTi1jJxOKYYJPYN3aSXdhOPGiqTpIjzn916OReD9khsQ00fJzS8+kevl5ow
zSpvolfGanqa4/y8eHLy/PhcXBy3QpGDntb6VDaKh1z9yRu7YJEy77keTz5BbyPo
sb0CtVGY/5Kf6Xb4flUjo7zg/gziBVnH7c1uCF4WFWMWGRY/gps+jpOYyZM+5lAN
v8COFOt6t6l3/xnu2Lymm4vOzj00iZf8hL29L19chwjdjm53U4HuIE7eYJvdaWqW
K5ayLezOnyX+GEm9ODJpI5Ogc/1C8rhbmLZgmZv/Tau5Pq0Ij8AoRgzdpvQkMBkJ
KS3n+XGDShIIU4pt0mhg/gp5Bc8CmSZrkgmnPtmm1pIym4csj1nf4k28vH7eOh7i
bBL0BRK2CuQ=
=fGN1
-----END PGP SIGNATURE-----

--=-JMBfETpio6Ih2NlygJHe--
