From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v2] typhoon: Use request_firmware()
Date: Mon, 02 Mar 2009 01:02:54 +0000
Message-ID: <1235955774.3251.6.camel@bunthorne.i.decadent.org.uk>
References: <1235324217.2832.49.camel@hashbaz.i.decadent.org.uk>
	 <20090226134950.GA975@decadentplace.org.uk>
	 <1235939916.22828.7.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-Uveh489crA5Ram5KRdUi"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David Dillow <dave@thedillows.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:1157 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751475AbZCBBDE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2009 20:03:04 -0500
In-Reply-To: <1235939916.22828.7.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Uveh489crA5Ram5KRdUi
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2009-03-01 at 15:38 -0500, David Dillow wrote:
> On Thu, 2009-02-26 at 13:49 +0000, Ben Hutchings wrote:
> > Based on a patch by Jaswinder Singh <jaswinder@infradead.org>.
> >=20
> > Compile-tested only.
> >=20
> > Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
>=20
> I suppose it's my fault for not getting around to this sooner, but I've
> been waiting for the fallout to settle with tg3 and follow the leader.
>=20
> Anyways, is it too much to ask for you to CC the maintainer? Hell, you
> added a line right above my email address, so it wouldn't have been hard
> for you to find...

Sorry about that - I looked for a maintainer but there was no listing
for "typhoon" in MAINTAINERS nor any recent change to the driver that
was not part of a general API change.  Email addresses in source files
tend to be outdated, so I didn't look for them.  I see now that you have
an entry under "3CR990" in MAINTAINERS, but that isn't the driver name.
Please could you change that so that it's easier for people to find you?

> I suppose I better test this sooner rather than later, because I think
> you've broken it. The firmware gets vmalloc'd, which means it is not
> necessarily physically contiguous, and I don't think pci_map_single() is
> going to like that since the firmware is always larger than a page. But
> I may be wrong on this.

You could well be right.

Ben.

--=20
Ben Hutchings
In a hierarchy, every employee tends to rise to his level of incompetence.

--=-Uveh489crA5Ram5KRdUi
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iD8DBQBJqzA579ZNCRIGYgcRAkStAJ9S3KukDU5TRm9bY0SyLf3H2OG4CQCdGBhk
fJw8D37wR7/3y1uawShzqqY=
=WUP7
-----END PGP SIGNATURE-----

--=-Uveh489crA5Ram5KRdUi--
