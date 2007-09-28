From: Andrey Borzenkov <arvidjaar@mail.ru>
Subject: Re: 2.6.23-rc8: cannot make netconsole work
Date: Fri, 28 Sep 2007 22:16:28 +0400
Message-ID: <200709282216.29279.arvidjaar@mail.ru>
References: <200709281327.59317.arvidjaar@mail.ru> <20070928153253.GV19691@waste.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart4055419.Mn1ZZTAFMy";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx5.mail.ru ([194.67.23.25]:10402 "EHLO mx5.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757787AbXI1SQd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Sep 2007 14:16:33 -0400
In-Reply-To: <20070928153253.GV19691@waste.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart4055419.Mn1ZZTAFMy
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Friday 28 September 2007, Matt Mackall wrote:
> On Fri, Sep 28, 2007 at 01:27:55PM +0400, Andrey Borzenkov wrote:
[...]
> > sudo modprobe netconsole netconsole=3D@/eth0,@/
> >
[...]
> What is your console log level set to? If the messages don't come out
> on the local console, they won't get sent out the network either.
> Fedora at least defaults to hiding most messages. Adding 'debug' to
> your kernel command line will change that.


Well, that was one thing; but for whatever reason it would refuse to work=20
without explicit MAC of recipient. Adding it made it (but it was of no help=
=20
to my original issue ... well, that is another story ...)

Thank you

=2Dandrey

--nextPart4055419.Mn1ZZTAFMy
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQBG/UT9R6LMutpd94wRApkcAKClnEOfIyIQu9rnKNL2STfJx73h/wCgiBAh
N9CxcIU9fJD4yBbsZdQ56P8=
=k5wp
-----END PGP SIGNATURE-----

--nextPart4055419.Mn1ZZTAFMy--
