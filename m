From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [patch 1/2] smsc-ircc2: wrap PNP probe code in #ifdef
 CONFIG_PNP
Date: Sat, 3 May 2008 11:46:17 +1000
Message-ID: <20080503114617.1c063759.sfr@canb.auug.org.au>
References: <200805022040.m42KeN16013646@imap1.linux-foundation.org>
	<20080502143802.8fb86319.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Sat__3_May_2008_11_46_17_+1000_rUDEj461qtpsFK1k"
Cc: samuel@sortiz.org, netdev@vger.kernel.org, bjorn.helgaas@hp.com,
	kamalesh@linux.vnet.ibm.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:55415 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754622AbYECBqY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 May 2008 21:46:24 -0400
In-Reply-To: <20080502143802.8fb86319.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Sat__3_May_2008_11_46_17_+1000_rUDEj461qtpsFK1k
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Fri, 2 May 2008 14:38:02 -0700 Andrew Morton <akpm@linux-foundation.org>=
 wrote:
>
> On Fri, 02 May 2008 13:40:23 -0700
> akpm@linux-foundation.org wrote:
>=20
> > From: Bjorn Helgaas <bjorn.helgaas@hp.com>
> >=20
> > Wrap PNP probe code in #ifdef CONFIG_PNP.
> >=20
> > Without this change, we'll have unresolved references to pnp_get_resour=
ce()
> > function when CONFIG_PNP=3Dn.  (This is a new interface that's not in m=
ainline
> > yet.)
>=20
> hrm, it turns out that this is already in linux-next, only I'm
> not sure by what route it got there.

I put it there directly at the end so that the tee would build for various
configs.  I have been carrying it for some time.  I am also carrying a
similar patch for nsc-ircc.  I will remove them when someone puts them
into some other tree that I am merging.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Sat__3_May_2008_11_46_17_+1000_rUDEj461qtpsFK1k
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFIG8PuTgG2atn1QN8RAhOIAJ9f4P+Nvv4/3iwdwoLuhEi8cqf9/gCffSOY
jJGOsYVOBkwt4FJmCz1Xdvc=
=VsZK
-----END PGP SIGNATURE-----

--Signature=_Sat__3_May_2008_11_46_17_+1000_rUDEj461qtpsFK1k--
