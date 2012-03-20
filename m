From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: netlink: 12 bytes leftover after parsing attributes - triggered
 by iproute2 libnetlink's rtnl_dump_request()
Date: Tue, 20 Mar 2012 15:00:30 +0000
Message-ID: <1332255630.8043.11.camel@deadeye>
References: <20120320134107.6acea83c@pluto.restena.lu>
	 <20120320074140.39a1b3f0@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-EWDK+6KGmgCYzgixGK+D"
Cc: Bruno =?ISO-8859-1?Q?Pr=E9mont?= <bonbons@linux-vserver.org>,
	netdev@vger.kernel.org, Greg Rose <gregory.v.rose@intel.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52604 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760119Ab2CTPAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2012 11:00:47 -0400
In-Reply-To: <20120320074140.39a1b3f0@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-EWDK+6KGmgCYzgixGK+D
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2012-03-20 at 07:41 -0700, Stephen Hemminger wrote:
>=20
> >=20
> > Should this get fixed at kernel level, iproute2 libnetlink level or
> > at end-user level (e.g. collectd)?
> > Three lines every 10 seconds is a damn lot!
> >=20
> > Thanks,
> > Bruno
>=20
> Netlink is supposed to be encoded as Type-Length-Value and correctly writ=
ten
> programs ignore types they don't understand. So either the library is get=
ting
> confused by the type or the attribute is not encoded correctly.
>=20
>=20
> The issue could be in libnetlink library. What version of collectd and li=
bnetlink
> are you using?

This was also reported as provoked by a client using the ntrack
rtnetlink code: http://thread.gmane.org/gmane.linux.network/224236

Ben.

--=20
Ben Hutchings
I'm always amazed by the number of people who take up solipsism because
they heard someone else explain it. - E*Borg on alt.fan.pratchett

--=-EWDK+6KGmgCYzgixGK+D
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAT2ibjue/yOyVhhEJAQqs8hAApYnir3cU4Q6iZmJLnfKMrS3/Mpps+ZQ9
raJxw8k1YN5lMEjALblGRdMjToueimbkrxHUPm3rBpa3w8wSi5X3ZzgB5Mb1WSyr
IaKGPWz4/F/2z1saFCnlVEuEKQ/2stP3M0uuL+qYvkUFbs+HX7X/b+TzbHRNGoVq
s6cyjVKIbZJxHxGPsSqDfaqMtt+Es4WJvvj2atcvh1JAIrN7HZ8bmxgaUYYnIOjx
szcfTsK6QDRgUVB+iMGPRX7bZ0RUNQF3xwppARBDWZMG9tHoCQNQJ15ToqAn6naZ
7GkWx+wASibp5PbsLkknWddBGi7nVMqjhdLkiKm8waxigAjG5pUv9ZsSSeMyBnuU
BUg/clA2MaL8kpOBCLx/TjkSmXa9INSGYS944MednOqErYQ4pk7RxS1/fkMU48lt
MyTamJBdx928i9pAljIe8c7jn9GD3xI5uFGKAEOwkjsFuvQXEVTc4Ljcj0MMIdjs
pX8bHfbeqxOWkMDx4zXO9hscT8Pv48MadiMlPasKiBXMXAdpSWK9/JzcdVbBv/iH
gKofpH6h7ht41UrpDAm1i0K+qzDe9qYEh478A5CpwPFBHmtOt2K8hwFTZ3mYLqU0
gZLmuFCXYHphipWhCBdvrf6AklGYKZtIJt4AvdI4XB0iRkjfK6okOCHgcURFI2Oa
JfD+9qFDn60=
=x3eH
-----END PGP SIGNATURE-----

--=-EWDK+6KGmgCYzgixGK+D--
