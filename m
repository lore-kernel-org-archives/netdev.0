From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: TXQ real_num_tx_queues comments/questions
Date: Tue, 15 Jul 2008 11:49:09 +0200
Message-ID: <1216115349.3535.20.camel@johannes.berg>
References: <1216113923.3535.14.camel@johannes.berg>
	 <20080715.022854.55875400.davem@davemloft.net>
	 <1216114621.3535.18.camel@johannes.berg>
	 <20080715.023954.234208581.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-0c/p5HOpQIOIvObg05Yr"
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:60656 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754504AbYGOJtK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 05:49:10 -0400
In-Reply-To: <20080715.023954.234208581.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-0c/p5HOpQIOIvObg05Yr
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2008-07-15 at 02:39 -0700, David Miller wrote:
> From: Johannes Berg <johannes@sipsolutions.net>
> Date: Tue, 15 Jul 2008 11:37:01 +0200
>=20
> > From mac80211's POV it's just that select_queue must have known
> > about the removed queue when the requeue is done. And we can defer
> > the requeue to a workqueue.
>=20
> Ok.
>=20
> So you're proposing the requeue be deferred to a workqueue
> and what else?  RCU protection around real_num_tx_queues
> access?

Yes, I think we can fix it by deferring the requeue to a workqueue,
using synchronize_net() and putting RCU protection against the
select_queue call.

johannes

--=-0c/p5HOpQIOIvObg05Yr
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJIfHKPAAoJEKVg1VMiehFYvdoP/RZM5q5Z87/irZxHZNrVKZwD
nOin2ydnuqDOPwIKmOppX+4CaAZO+KwiB/7UbPYWSQLKNnd9Q8+96VWRmOmivPpl
JAYJemfaIiDX+JERduKOT4nqI+1PoDFdnBeahhUfAgXmFWjoanhbR0LddD498Lc3
PAPqW7MGci7TlLi3E0q7H2RYSPFdccwSGjMJYCEp2m9NsUgfP4fYT1iIt/ZY4mRi
rzrKxO0MSd0s16e5ByC/RbVrxkq7Ut1Jh1TAjkHgwEZh5FtbM4oJWL5eLQg/vpRl
5+AOtUxA/dLapULo7VNqXypbGbOZd+vrwNQ/WqqX9GWgtS0fgtypkTJ9ss4bCooG
YIOVg+L+s5jH5mbJbvlwUCWEz8e/LEQX4N9CYRgJTQTSHrmWUXy6Rgg/z1ejmUkx
3lacX6KfOfPv5kXPlG0aWas1YlhJic2Aar9/82qLk202SK1ZNX0rHhOuzt3pGi0Y
xcjUBsayez7YY4UKrfCpEJYFiHq33o4ORgXJ8lyrnFWgK8O5p83B6jN7b7yiEvpI
AUdw5K3aGj+ITVif5KObLqZkwNIvJ/z2poObpPeUMtg15e6ansGbNBSaeA5yeJn3
/0UF8JlhWrVGLKTPxq5C2Y8adBv7lBVdJ20xU/tzMrLK7OMLcIw2xp6Srru1mEL4
Re1LXIKyRi6HE/vRylsF
=/VVO
-----END PGP SIGNATURE-----

--=-0c/p5HOpQIOIvObg05Yr--

