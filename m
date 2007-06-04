From: Nigel Cunningham <nigel@nigel.suspend2.net>
Subject: Re: [RFC][PATCH] Add suspend and resume support to uli526x
Date: Tue, 05 Jun 2007 08:49:04 +1000
Message-ID: <1180997344.4356.74.camel@nigel.suspend2.net>
References: <200706031237.36773.rjw@sisk.pl>
	 <20070604111112.GP4363@elf.ucw.cz> <200706041549.11277.rjw@sisk.pl>
	 <1180991794.4356.31.camel@nigel.suspend2.net>
	 <20070604224146.GE2711@elf.ucw.cz>
Reply-To: nigel@nigel.suspend2.net
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-CRZ8OdCgCA22UW5ykdLK"
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	linux-pm <linux-pm@lists.osdl.org>, netdev@vger.kernel.org,
	Valerie Henson <val@nmt.edu>, Peer Chen <peer.chen@uli.com.tw>
To: Pavel Machek <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nigel.suspend2.net ([203.171.70.205]:47424 "EHLO
	nigel.suspend2.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753262AbXFDWtD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2007 18:49:03 -0400
In-Reply-To: <20070604224146.GE2711@elf.ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-CRZ8OdCgCA22UW5ykdLK
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hi.

On Tue, 2007-06-05 at 00:41 +0200, Pavel Machek wrote:
> Hi!
>=20
> > > > > +#endif /* CONFIG_PM */
> > > >=20
> > > > > @@ -1689,6 +1775,10 @@ static struct pci_driver uli526x_driver=20
> > > > >  	.id_table	=3D uli526x_pci_tbl,
> > > > >  	.probe		=3D uli526x_init_one,
> > > > >  	.remove		=3D __devexit_p(uli526x_remove_one),
> > > > > +#ifdef CONFIG_PM
> > > > > +	.suspend	=3D uli526x_suspend,
> > > > > +	.resume		=3D uli526x_resume,
> > > > > +#endif
> > > >=20
> > > > ...so that this ifdef is not needed?
> > >=20
> > > OK, why not.
> >=20
> > Because it's uglier and #ifdef is the established way of doing things?
>=20
> Actually the way I suggested is nicer, IIRC akpm invented it. It keeps
> ifdefs localized around the block that _needs_ to be ifdefed.

The localised point is true. I'll also admit that 'nicer'/'uglier' is a
matter of aesthetics and therefore personal opinion.

I guess that leaves the question, "What's the precedent to follow?" or
"Is there a driver that's already got this new format?".

Regards,

Nigel

--=-CRZ8OdCgCA22UW5ykdLK
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBGZJbgN0y+n1M3mo0RAsJKAJsELp+G9kWI52p+YsMNropxBoiSkwCg56lO
RsrJ6RGY9QkPqvbkjyhRNw4=
=AWDz
-----END PGP SIGNATURE-----

--=-CRZ8OdCgCA22UW5ykdLK--

