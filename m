From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: wireless extensions vs. 64-bit architectures
Date: Thu, 08 Mar 2007 20:23:26 +0100
Message-ID: <1173381806.3248.58.camel@johannes.berg>
References: <1173144447.15891.93.camel@johannes.berg>
	 <20070306171316.GA19669@bougret.hpl.hp.com>
	 <200703061943.07350.mb@bu3sch.de>
	 <20070307020310.GA20466@bougret.hpl.hp.com>
	 <1173364747.14001.7.camel@johannes.berg>
	 <20070308184954.GA24485@bougret.hpl.hp.com>
	 <1173380909.3248.52.camel@johannes.berg>
	 <20070308191322.GA24598@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-7xV/oHDBT9v20XS6TKXv"
Cc: Michael Buesch <mb@bu3sch.de>, linux-wireless@vger.kernel.org,
	netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	Dan Williams <dcbw@redhat.com>,
	Jouni Malinen <jkm@devicescape.com>
To: jt@hpl.hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:35596 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933057AbXCHTXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2007 14:23:39 -0500
In-Reply-To: <20070308191322.GA24598@bougret.hpl.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-7xV/oHDBT9v20XS6TKXv
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2007-03-08 at 11:13 -0800, Jean Tourrilhes wrote:

> 	I'm looking into that. The good thing is that we have
> redundant information, so we can check that things don't match. It's a
> bit more complex because some of those take variable parameters.

Yeah, and it also only happens with those event streams I think. But I
haven't checked other possible places.

> > I'd think this is a kernel bug and 32-bit userspace should rightfully b=
e
> > able to expect 32-bit aligned structs, no? Actually fixing it in the
> > kernel would not be trivial though.
>=20
> 	What we could do is have every 64 bit kernel return things on
> a 32 bit boundary, irrespective of userspace used. That would break
> current 64 bit userspace.

Yeah, the only way to fix the bug without breaking that would be to
return different structs for the different userspaces which sounds
really complex.

johannes

--=-7xV/oHDBT9v20XS6TKXv
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBF8GKu/ETPhpq3jKURAsK5AJ98SDBT+IQsa3bfU6rq6FYnEH6czQCdGH7i
s5GvbCBz2RpfnMTuJ6pg+tU=
=9qQW
-----END PGP SIGNATURE-----

--=-7xV/oHDBT9v20XS6TKXv--

