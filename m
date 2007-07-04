From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: multicasting netlink messages to groups > 31 from userspace
Date: Wed, 04 Jul 2007 17:08:33 +0200
Message-ID: <1183561713.9662.5.camel@johannes.berg>
References: <1183492286.4021.21.camel@johannes.berg>
	 <468BAADC.4030203@trash.net> <1183558702.3812.33.camel@johannes.berg>
	 <468BAF10.6080208@trash.net> <1183559883.3812.42.camel@johannes.berg>
	 <468BB327.5050709@trash.net> <1183561006.3812.47.camel@johannes.berg>
	 <468BB5F8.3080908@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-WFn+P5g8RWozaj16cI6g"
Cc: netdev <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Thomas Graf <tgraf@suug.ch>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:38187 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755215AbXGDPHo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2007 11:07:44 -0400
In-Reply-To: <468BB5F8.3080908@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-WFn+P5g8RWozaj16cI6g
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-07-04 at 17:00 +0200, Patrick McHardy wrote:

> Not by itself probably but a user could DoS your wireless connectivity
> this way.

Hmm, if anything then not the connectivity but rather the MLME i.e. it
won't do roaming properly maybe. Maybe we should then have a way to say
that somebody only wants to receive messages from privileged users, that
way the MLME process wouldn't be affected.

> I'm not sure, it would probably also have to be called when userspace
> unsubscribes from a group, no?

No actually having that hook means I can do without multicast groups by
just publishing that "send configuration requests to pid N" where N is
either 0 (in-kernel MLME) or something else (userspace MLME); I just
didn't know the hook existed.

Not that we shouldn't fix the multicast issues anyway though the one
from this particular thread wouldn't be too interesting right now until
somebody needs userspace to multicast; the other three patches still
should be done now before there are more generic netlink multicast
users.

johannes

--=-WFn+P5g8RWozaj16cI6g
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGi7fx/ETPhpq3jKURApQMAKCgpJ67ScJNJOdSWkpqhJ0E1T9tHACgtVVN
9YqA1ORKAcJOaKTyKg9IZA4=
=dRcS
-----END PGP SIGNATURE-----

--=-WFn+P5g8RWozaj16cI6g--

