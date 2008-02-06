From: Michael Pyne <mpyne@purinchu.net>
Subject: Re: [patch 2/4] forcedeth: fix MAC address detection on network card (regression in 2.6.23)
 =?iso-8859-1?q?=00?=
Date: Tue, 5 Feb 2008 21:06:27 -0500
Message-ID: <200802052106.36012.mpyne@purinchu.net>
References: <200802050746.m157ktY9010399@imap1.linux-foundation.org> <47A8B558.7060605@garzik.org> <47A751F6.3030007@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1476200.t4yC2puYNs";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, michael.pyne@kdemail.net,
	LKML <linux-kernel@vger.kernel.org>
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hapkido.dreamhost.com ([66.33.216.122]:52178 "EHLO
	hapkido.dreamhost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758939AbYBFCJE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 21:09:04 -0500
In-Reply-To: <47A751F6.3030007@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart1476200.t4yC2puYNs
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Monday 04 February 2008, Ayaz Abdulla wrote:
> Jeff Garzik wrote:
> > Ayaz Abdulla wrote:
> >> I believe Michael determined that a newer BIOS fixes this issue.
> >
> > That's a solution that makes vendors happy... but we still have to deal
> > with it in Linux.  There are plenty of the old broken BIOS still out in
> > the field...
> >
> >     Jeff
>
> Michael, can you provide which BIOS version had this issue and which
> version fixed the issue?

Ayaz,

One of my earlier messages to the list was from BIOS revision F3 from what =
I=20
can tell (which matches pretty well with what I remember having).  I am=20
currently on F8.

I may go back to F3 if I can get booting from USB to work just to verify=20
because I could have sworn it was still broken after going to F8.  But sinc=
e=20
unpatched Linux 2.6.23.12 apparently works fine and I'm not sure when exact=
ly=20
that happened (I use Ketchup to maintain the sources and somewhere it=20
unpatched my forcedeth.c :) I want to double-check that a simple BIOS upgra=
de=20
will solve it.

But I also don't have a lot of time before I go underway for a few months. =
:-/

Regards,
 - Michael Pyne

--nextPart1476200.t4yC2puYNs
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.7 (GNU/Linux)

iD8DBQBHqRYrqjQYp5Omm0oRAvAiAKC9insSAx1QZ3gSdrzWqXHdLQdIQQCfZyf9
1mURTWfRPFp5Sel66amOXUc=
=nZrB
-----END PGP SIGNATURE-----

--nextPart1476200.t4yC2puYNs--
