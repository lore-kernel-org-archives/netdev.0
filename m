From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 1/1] smsc95xx: add FLAG_POINTTOPOINT flag for driver_info
Date: Thu, 17 May 2012 12:45:59 +0100
Message-ID: <1337255159.4107.67.camel@deadeye>
References: <1337155302-26244-1-git-send-email-jgq516@gmail.com>
	 <1337168320.4107.42.camel@deadeye> <4FB4B98E.7000208@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-XexRGYIYI91xrsiTF1q5"
Cc: steve.glendinning@smsc.com, gregkh@linuxfoundation.org,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Xiao Jiang <jgq516@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:34297 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750835Ab2EQLqR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 07:46:17 -0400
In-Reply-To: <4FB4B98E.7000208@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-XexRGYIYI91xrsiTF1q5
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2012-05-17 at 16:40 +0800, Xiao Jiang wrote:
> Ben Hutchings wrote:
> > On Wed, 2012-05-16 at 16:01 +0800, jgq516@gmail.com wrote:
> >  =20
> >> From: Xiao Jiang <jgq516@gmail.com>
> >>
> >> commit c26134 introduced FLAG_POINTTOPOINT flag for USB ethernet devic=
es
> >> which possibly use "usb%d" names, add this flag to make sure pandaboar=
d
> >> can mount nfs with smsc95xx NIC.
> >>    =20
> >
> > These are normal Ethernet interfaces, whereas FLAG_POINTTOPOINT is for
> > devices that use non-standard short physical links.
> >
> >  =20
> This flag is used by some usb NICs, I amn't familiar with those cards=20
> perhaps those are
> non-standard short physical links as you said.
> But smsc95xx seems need this flag to use "usb%d" name,

But this is a regular Ethernet interface and should be named
accordingly.

> at least my=20
> pandaboard can't
> mount nfs with eth0 name, is there other ways to avoid nfs issue with=20
> keep smsc95xx's
> name unchange? thanks.
[...]

I don't know what this NFS issue is, but I don't see how this can be the
correct solution.

Ben.

--=20
Ben Hutchings
Every program is either trivial or else contains at least one bug

--=-XexRGYIYI91xrsiTF1q5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAT7Tk9+e/yOyVhhEJAQq+5BAAx+C9OlCRObpeR7pFQBp3BjUEaqEfith9
lgl+ioFJ6VgRDE6otYwOKTqb54uerrHIZMOvm7BNyJDeWCakzzxWaflI2v8vVIRU
al89lI+U89Im30zrfAxEyPZsmn6BmVEK/gTfnCdfr9p9o79tHjvpe68vNHI3BXDL
NSgw9PwbiARQc7L/HuvSy79yiEN/401O4Eg+Mu17uwyDULn9fbvqSR9NGpR32IYP
nKG4EPzAv+YSCEphmHetdoFKLknvjlAYhSisMqbB6rcu++xHfHMKHpqJ6b5v7ND8
8QHfmO4JUABlN18Q4tNMJZ/DtTwMKMMXeEYW8tsZ95VxOxiY5Na2wu+IIYPwkiuh
8tY5w6kxXkFj95lPMUSLl4ywqHX5MWFD47+BP8Tkyl4MzWxzYWBpPr01SQg9aZGe
xp3lcVPzrIpDD2CoxVL049FFKo8R2ly2hoMtneQ8veQ22pcb/XslApAD+MXIyijZ
57A2+SXDbUow8sutaaJodJAFEOJjpgAtIFm7yzmEay4HRwAPfmCN+FYYQOVjoNR8
mkktl8CSddaYT0Y1979tg5MWS/1qBfu3TuTCQYd516FWQ/6wACm8YIhQcRigvKRA
H5brZj1WZaLLwyuPqOLaZmFqE2XCEAfDxJLpOozPV7wN05CfbJool7+Ixl8Cjv6V
ao33R00LWCo=
=Y0yD
-----END PGP SIGNATURE-----

--=-XexRGYIYI91xrsiTF1q5--
