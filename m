From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [patch 1/2] smsc-ircc2: wrap PNP probe code in #ifdef
 CONFIG_PNP
Date: Sat, 3 May 2008 14:26:03 +1000
Message-ID: <20080503142603.859b6c86.sfr@canb.auug.org.au>
References: <200805022040.m42KeN16013646@imap1.linux-foundation.org>
	<20080502143802.8fb86319.akpm@linux-foundation.org>
	<20080503114617.1c063759.sfr@canb.auug.org.au>
	<20080502185511.f20525b2.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Sat__3_May_2008_14_26_03_+1000_0An_IyYs=_1UYu/P"
Cc: samuel@sortiz.org, netdev@vger.kernel.org, bjorn.helgaas@hp.com,
	kamalesh@linux.vnet.ibm.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:41891 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751161AbYECE0N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 May 2008 00:26:13 -0400
In-Reply-To: <20080502185511.f20525b2.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Sat__3_May_2008_14_26_03_+1000_0An_IyYs=_1UYu/P
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Fri, 2 May 2008 18:55:11 -0700 Andrew Morton <akpm@linux-foundation.org>=
 wrote:
>
> On Sat, 3 May 2008 11:46:17 +1000 Stephen Rothwell <sfr@canb.auug.org.au>=
 wrote:
>=20
> > I put it there directly at the end so that the tee would build for vari=
ous
> > configs.  I have been carrying it for some time.  I am also carrying a
> > similar patch for nsc-ircc.  I will remove them when someone puts them
> > into some other tree that I am merging.
>=20
> argh, that's a process problem.

Yeah, I guessed it might be :-)

> When those patches turn up in linux-next, I will assume that someone merg=
ed
> them into a git tree and I will drop them.
>=20
> You now own the sole copy.  If you drop them, they are lost.  If you don't
> send them to anyone, you own them forever.
>=20
> So..  what to do about this?  I think the only solution is for you to go
> into akpm mode and start desperately trying to entice someone into merging
> the patch.

I can cope with that.  There are some patches I need to have so that
particular trees/configs will build.  It is rare, though.  Normally I
would revert the problematic patch (and push the problem back on the
subsystem/patch owner.  When I grabbed those particular patches, I was
assuming that it would be a short term thing as all the appropriate
people had been notified.

The other turds you will see will be small semi-private fixup patches
that I do myself and send back to the appropriate people until they fix
their tree - these patches rarely last more than a day and are rolled
into the original offending patch or something similar is added to the
offending tree.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Sat__3_May_2008_14_26_03_+1000_0An_IyYs=_1UYu/P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFIG+ljTgG2atn1QN8RAl0zAJ0T57v0Z6oJobyffCV3uq0f16UndACeK9na
Fmk/ZsbvMKF+BIw098Ky0Ag=
=bd6Q
-----END PGP SIGNATURE-----

--Signature=_Sat__3_May_2008_14_26_03_+1000_0An_IyYs=_1UYu/P--
