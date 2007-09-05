From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: WiFi and changed MAC addrs
Date: Wed, 05 Sep 2007 17:34:44 +0200
Message-ID: <1189006484.9942.113.camel@johannes.berg>
References: <46DEC94C.9010301@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-BWi9W9xByjoLLGBbK50N"
Cc: netdev@vger.kernel.org
To: Ben Woodard <woodard@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:46871 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755938AbXIEPdT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2007 11:33:19 -0400
In-Reply-To: <46DEC94C.9010301@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-BWi9W9xByjoLLGBbK50N
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-09-05 at 08:20 -0700, Ben Woodard wrote:

> If a particular piece of hardware will refuse to send frames after the=20
> MAC address has been changed, then shouldn't the card's driver refuse to=20
> allow a change of the MAC address and return an error in response to the=20
> IOCTL that tries to change it?

Yes.

> I can't think of a situation where this=20
> wouldn't be the right thing to do. However, before I submit a patch to=20
> fix this, does anyone else know of any special cases that I might need=20
> to deal with?

That wouldn't make sense now, would it?

> Also is behavior of refusing to send frames with a non-hardware=20
> specified MAC address part of the WiFi spec or is it particular to=20
> certain WiFi cards? IOW at what level do I need to fix it? Should I just=20
> fix it for the Intel cards that I've tested or do I need to fix it for=20
> all WiFi cards?

Most wifi cards don't care at all what MAC address you send, in fact
allowing you to send with various MAC addresses. So this is something
intel specific. Oh are we talking about iwlwifi? If so, please report to
their maintainers immediately, they're lazy bastards and don't even
upload the new MAC address to the card even if they could.

johannes

--=-BWi9W9xByjoLLGBbK50N
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBG3syT/ETPhpq3jKURAt+qAJ9sAIybbZy+DERHWVAMjpZgZRZqEgCgoPMT
Mgq0O6jG2txel11NagCbv/s=
=1oDs
-----END PGP SIGNATURE-----

--=-BWi9W9xByjoLLGBbK50N--

