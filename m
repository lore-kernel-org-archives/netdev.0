From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: multicasting netlink messages to groups > 31 from userspace
Date: Fri, 06 Jul 2007 12:53:52 +0200
Message-ID: <1183719232.3818.109.camel@johannes.berg>
References: <1183492286.4021.21.camel@johannes.berg>
	 <468BAADC.4030203@trash.net> <1183558702.3812.33.camel@johannes.berg>
	 <468BAF10.6080208@trash.net> <1183559883.3812.42.camel@johannes.berg>
	 <468BB327.5050709@trash.net> <1183561006.3812.47.camel@johannes.berg>
	 <468BB5F8.3080908@trash.net> <1183561713.9662.5.camel@johannes.berg>
	 <468CF41E.4020409@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-8pU4lQBRotDObNjxCkPK"
Cc: netdev <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Thomas Graf <tgraf@suug.ch>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:36677 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756437AbXGFKwx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2007 06:52:53 -0400
In-Reply-To: <468CF41E.4020409@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-8pU4lQBRotDObNjxCkPK
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2007-07-05 at 15:37 +0200, Patrick McHardy wrote:

> Earlier filtering makes sense, especially for userspace. The other
> part exceeds my wireless knowledge :)

No worries. I'll see if I can come up with a way to do earlier
filtering, but it's not actually required for the functionality. And the
discussion in the wireless realm still isn't over.

> > No actually having that hook means I can do without multicast groups by
> > just publishing that "send configuration requests to pid N" where N is
> > either 0 (in-kernel MLME) or something else (userspace MLME); I just
> > didn't know the hook existed.
>=20
>=20
> Even better. Publishing that to userspace is going to be racy though.

I could instead have userspace always send message to 0 and just
redirect them to the userspace process if present; will have to look
into it. That wouldn't be racy at least, but I think this race is going
to be the least of your worries (if the userspace MLME just died then
you have to completely re-do all configuration anyway, and if it just
started the same)

> The genetlink stuff defintely makes sense. I'll have a closer look at
> your patches this weekend.

Thanks. I know Zhang Rui will definitely appreciate that too :)

johannes

--=-8pU4lQBRotDObNjxCkPK
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGjh9A/ETPhpq3jKURAvwmAJ4iA95HOGqf+oihOmf+3NVE5AT/9gCfaDyx
rWzYS656YDuW861QpwEM9pU=
=4alY
-----END PGP SIGNATURE-----

--=-8pU4lQBRotDObNjxCkPK--

