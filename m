From: Rene Mayrhofer <rene.mayrhofer@gibraltar.at>
Subject: Re: [PATCH] sky2: fix management of driver LED
Date: Wed, 2 Sep 2009 09:28:53 +0200
Message-ID: <200909020929.03231.rene.mayrhofer@gibraltar.at>
References: <4A9928C9.7000907@ring3k.org> <20090901.174437.145971351.davem@davemloft.net> <20090901213325.69b3348b@nehalam>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2166600.YBMhoiQ3nN";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, mikem@ring3k.org,
	netdev@vger.kernel.org, leitner@esys.at, hofer@esys.at
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jupiter1.gibraltar.at ([80.120.3.98]:34437 "EHLO
	mail1.gibraltar.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751987AbZIBH3L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 03:29:11 -0400
In-Reply-To: <20090901213325.69b3348b@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart2166600.YBMhoiQ3nN
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

On Wednesday 02 September 2009 06:33:25 am Stephen Hemminger wrote:
> On Tue, 01 Sep 2009 17:44:37 -0700 (PDT)
>
> David Miller <davem@davemloft.net> wrote:
> > From: Stephen Hemminger <shemminger@linux-foundation.org>
> > Date: Mon, 31 Aug 2009 10:31:41 -0700
> >
> > > Observed by Mike McCormack.
> > >
> > > The LED bit here is just a software controlled value used to
> > > turn on one of the LED's on some boards. The register value was wrong,
> > > which could have been causing some power control issues.
> > > Get rid of problematic define use the correct mask.
> > >
> > > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> >
> > Applied.
>
> If these power management fixes do fix all the reported problems,
> then I will consider back porting (probably to 2.6.31.1).

They don't, unfortunately (nonetheless, they should be applied). The bug is=
=20
still reproducible with this patch applied to the latest net-next version o=
f=20
sky2.[ch]. I am currently working on setting up a test environment to=20
reproduce the bug and access the system console (serial line) as well as ha=
rd=20
power reset. Both you and Mike (and David if it helps) will get the necessa=
ry=20
access so that you can debug more efficiently on the system itself (without=
 me=20
being in the middle, slowing things down). I hope to have everything ready =
in=20
an hour.

best regards,
Rene

=2D-=20
=2D------------------------------------------------
Gibraltar firewall       http://www.gibraltar.at/

--nextPart2166600.YBMhoiQ3nN
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkqeHroACgkQq7SPDcPCS9596gCfeRHdcHy/LGLRfOcGCSZf7rSw
UDkAn0TXOpNfKS7K7qTYFboSfHyVTp0h
=kDTP
-----END PGP SIGNATURE-----

--nextPart2166600.YBMhoiQ3nN--
