From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 2/2] ethtool: allow for a smaller build
Date: Thu, 27 Feb 2014 22:56:34 +0000
Message-ID: <1393541794.14067.76.camel@deadeye.wl.decadent.org.uk>
References: <1393464911-21593-1-git-send-email-f.fainelli@gmail.com>
	 <1393464911-21593-3-git-send-email-f.fainelli@gmail.com>
	 <063D6719AE5E284EB5DD2968C1650D6D0F6CC891@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-vhoNGo9URbUTz8sqE92w"
Cc: 'Florian Fainelli' <f.fainelli@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:46674 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751155AbaB0W4j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 17:56:39 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6CC891@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-vhoNGo9URbUTz8sqE92w
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-02-27 at 10:05 +0000, David Laight wrote:
> From: Florian Fainelli
> > Introduce a new configure script option: --enable-small which will
> > disable building the driver specific register dump objects, the savings
> > are:
> ...
> > +if !SMALL
> > +ethtool_SOURCES +=3D \
> >  		  amd8111e.c de2104x.c e100.c e1000.c et131x.c igb.c	\
> >  		  fec_8xx.c ibm_emac.c ixgb.c ixgbe.c natsemi.c	\
> >  		  pcnet32.c realtek.c tg3.c marvell.c vioc.c	\
> >  		  smsc911x.c at76c50x-usb.c sfc.c stmmac.c	\
> > -		  rxclass.c sfpid.c sfpdiag.c ixgbevf.c
> > +		  sfpid.c sfpdiag.c ixgbevf.c
> > +endif
>=20
> What about allowing a subset of the register dumps be enabled?

I'm not interested in this.

Ben.

--=20
Ben Hutchings
It is easier to change the specification to fit the program than vice versa=
.

--=-vhoNGo9URbUTz8sqE92w
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUw/Coue/yOyVhhEJAQprgQ//cJsw3T7t+6/l1VlgHKp+d/NHCl22Aj5J
ckh9rRaWoBJYUOMBNg80N83e88w5nG6IxC5jTQvtm4WS+2ib9lvXXeMS3Nc4kAlV
LqDPGUaP1ToA3HF8hyQwKPW4Gsc65Re6/hYVSH8L/wq5q++RBF0MMjLOG+lAKqmW
XCML62wrWDQ+vk1ngISls82dPX5HO+bhFyJybFzLLqGifEgAiwAwGENWbI8ocyTF
vdOCjpniqVv6uArqBQ2vkCBo4LTGAEgivNPxbiYipYtIFjrAK8cumJfu1i+q6Ju/
YP5xJ+mlukZIFC8zCJScZHWbRbUb/65k4klEsZis7DXJWtAPb4fMxJMpt+liqmJ7
esQZG5oSbMKXxh5FM1G17Mfp6wtQcrLDZ+nbl+MXbWW83xhX0AhQyO8SIVsJDECp
ApFTKnstieQ2TrdkLVz/1B0W/Ha3l3mKhiTEFGBQ12pnErczMsXD8krvbNpowfiL
EXAoRB2PHIVwDs8r2sRz9lBIV8UaMF2XYTARh8WlU6ombPvAbZjUCsbuA8H3Ils1
0XCjJ22QQLJMKmyNzT9o6VMb3FDO8kODcLTHsk0L8ZHW2UH1V/XD3c3XLih0MIeH
5kvh4fVlrKAt2YkIASvg23pp352gAB/dXnwNRyZGobfG4wWvyeiCC8jhWyNQtYBY
MrN0AbwISH0=
=tuF2
-----END PGP SIGNATURE-----

--=-vhoNGo9URbUTz8sqE92w--
