From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 4/6] d80211: don't display name of invisible network
	device
Date: Wed, 31 Jan 2007 19:58:58 +0100
Message-ID: <1170269938.2236.1.camel@johannes.berg>
References: <20070129174809.6401B48499@silver.suse.cz>
	 <1170164845.30318.19.camel@johannes.berg>
	 <58d0dbf10701300600h24cdb9b8xabbc27b16d4ddb05@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-TLsiP7GUCmLAXxcaAaZT"
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>
To: Jan Kiszka <jan.kiszka@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:41360 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030575AbXAaU63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jan 2007 15:58:29 -0500
In-Reply-To: <58d0dbf10701300600h24cdb9b8xabbc27b16d4ddb05@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-TLsiP7GUCmLAXxcaAaZT
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-01-30 at 15:00 +0100, Jan Kiszka wrote:

> > If the master netdev no longer has a name, how can you still use `tc' o=
n
> > it?
>=20
> I hope you can't,

You know, being able to is the only (user interface) reason for the
master dev's existence.

> because that was recently proven to be able to
> subtly break the stack:
>=20
> http://www.mail-archive.com/netdev@vger.kernel.org/msg29219.html

Well, that's a bug indeed, but the cure isn't "don't allow any qos
operations" but rather "don't allow removal of the 802.11 qdisc".

johannes

--=-TLsiP7GUCmLAXxcaAaZT
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFwOby/ETPhpq3jKURAuyiAJ4tWHz8zUCWdau+yvTZxPj5hchO5QCfaHS8
Z+o8UBdEduNWuC0Jhq1Xke8=
=usk/
-----END PGP SIGNATURE-----

--=-TLsiP7GUCmLAXxcaAaZT--

