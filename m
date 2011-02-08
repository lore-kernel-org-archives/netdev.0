From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [Bugme-new] [Bug 28542] New: 3c59x.c: Regression since 2.6.36
 (incl.), for e. g., TCP stalls on receive
Date: Tue, 08 Feb 2011 00:39:10 +0000
Message-ID: <1297125550.2876.21.camel@localhost>
References: <bug-28542-10286@https.bugzilla.kernel.org/>
	 <20110207150919.cd253b97.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-M5118eWFLJubnpQAwyPW"
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Jan Beulich <jbeulich@novell.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	Andrew Morton <akpm@linux-foundation.org>
To: for.poige+bugzilla.kernel.org@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:33902 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755396Ab1BHAjU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Feb 2011 19:39:20 -0500
In-Reply-To: <20110207150919.cd253b97.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-M5118eWFLJubnpQAwyPW
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2011-02-07 at 15:09 -0800, Andrew Morton wrote:
> On Mon, 7 Feb 2011 18:55:29 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
[...]
> > Dump of kernel source bz2 download being stalled:
> > http://poige.livejournal.com/475372.html#cutid1 (see the bunch of ACKs
> > #5555523).

That's not a stall, that's selective-ACKing (see the ranges listed on
the right of each ACK line).

> > As a workaround I've just replaced drivers/net/3c59x.c with its former
> > (2.6.35.11) version, the connectivity problems are gone now.

This could just be a coincidence.  But it could be that packet loss is
now more likely for some reason.  Does the rx_fifo_errors statistic
increase quickly with the later version of the driver?  (This seems to
be the only receive error type reported.)

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-M5118eWFLJubnpQAwyPW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUATVCQqOe/yOyVhhEJAQLmlQ//Vq2btEFtEKKAJnbFuVX+v23ol1QMKJs0
OB97D6LUz3JjcJZCYwmyTm3bafICf5FI6szEttoGHjit0ghRAwi3fsIkBfStCMcG
QHyoAbCjcytejr7R/8hgv6Z+6S+fxNAfdRJXVarwo3AheKDVyEw+9mOr6LUnze5o
F3zuHPcvrzdO3RQ3qdpOu0KXc3iJb1plxa+3JCqaqp4ZZiaF1Tzxn5gqT6cWIhMB
AR6lGmg6ri25p2l38KKwLradBJxNo8joY7ADkpvRLhIdsWw82ZF+KQwD/H7T/mnF
6+V9OwZkYFlNggQVv7Bh0hLY0UgTf4PcmJKIdLHWSa3Cioj6UF/v08rojFhMvRvi
YjG74nOyzv5PH6+IQEkYr26HU602KuBkkiwTAj7QfXsh8RIRBve7konR/fzkCQuL
9TmAEbVdVwDmPk8OnoLf3macgr97bB5/po7BqD6Wn6rJBevCf+EiAuZCInsH/nEK
sNFXbCHXOtjduhfV78nshcM+nbIEdScR3nwHwdhkfbtW+ExnbOx42xjlo3b9L5DD
KejpwttxBAOe9+9/0nnbq6/cTvWD0cc5ltH1n3CSmwXpyjorYNALQ4cX0LNi1sRw
QHDsQaJKszRlIwMzM7AhMmvKyKW1Euqf8v6/v4tS5FlKcJLzxS1qDV8UeRUR72xB
sI87+ZDiRk0=
=fk+g
-----END PGP SIGNATURE-----

--=-M5118eWFLJubnpQAwyPW--
