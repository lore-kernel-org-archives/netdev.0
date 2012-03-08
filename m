From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH] bridge: fix "entering disabled state" logging
Date: Thu, 8 Mar 2012 04:59:14 +0100
Message-ID: <20120308035914.GK591081@jupiter.n2.diac24.net>
References: <20120306142219.31783.30201.stgit@localhost.localdomain>
 <20120306.143323.1591818099708591757.davem@davemloft.net>
 <4F571674.6000107@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="8tUgZ4IE8L4vmMyh"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: Paulius Zaleckas <paulius.zaleckas@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:52642 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754963Ab2CHD7Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Mar 2012 22:59:24 -0500
Content-Disposition: inline
In-Reply-To: <4F571674.6000107@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--8tUgZ4IE8L4vmMyh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Mar 07, 2012 at 10:04:04AM +0200, Paulius Zaleckas wrote:
> On 03/06/2012 09:33 PM, David Miller wrote:
> > From: Paulius Zaleckas<paulius.zaleckas@gmail.com>
> > Date: Tue, 06 Mar 2012 16:22:19 +0200
> >
> >> Now we have:
> >> eth0: link *down*
> >> br0: port 1(eth0) entering *forwarding* state
> >>
> >> State should be logged *after* it was changed, not before.
> >>
> >> Reported-by: Zilvinas Valinskas<zilvinas@wilibox.com>
> >> Signed-off-by: Paulius Zaleckas<paulius.zaleckas@gmail.com>
> >
> > This is intentional, this was a discussion about this.
> >
> > "Entering" means "about to" therefore we say it before it happens.
>=20
> You have missed the whole point here... please look at dmesg output, I=20
> have bolded what you should pay attention to. It should say "entering=20
> disabled state" instead of "entering forwarding state".

To make this even more clear so it's not dismissed another time:

it says "entering forwarding state" when it is actually entering
disabled state. Because the print references the value before the
change. Which is changed to disabled just after.

Whatever the tense of the verb, it prints the state that's just being
left instead of the one being entered.


-David

--8tUgZ4IE8L4vmMyh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iF4EAREIAAYFAk9YLpIACgkQCy20tTec6ePuyQD+MZ8fMsZzELeAm7yp7ZFhRsuE
EPlOjlAwEtQ0kU9wlZkA/Ah634DowvybenpZpR8K9Vibn/lDBbyGUk/Whmhoz/YS
=jNaB
-----END PGP SIGNATURE-----

--8tUgZ4IE8L4vmMyh--
