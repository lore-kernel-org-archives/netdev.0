From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: ethtool: git tree not updated to v3.18
Date: Thu, 02 Apr 2015 19:23:13 +0100
Message-ID: <1427998993.28415.5.camel@decadent.org.uk>
References: <20150401143006.000001f7@unknown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-qLH4zezyZNcEDxS6SMTV"
Cc: netdev@vger.kernel.org
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53984 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750829AbbDBSX1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 14:23:27 -0400
In-Reply-To: <20150401143006.000001f7@unknown>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-qLH4zezyZNcEDxS6SMTV
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-04-01 at 14:30 -0700, Jesse Brandeburg wrote:
> Hi Ben,=20
>=20
> When trying to check a bug just now I noticed that the master
> branch of
> git://git.kernel.org/pub/scm/network/ethtool/ethtool
>=20
> still points to the v3.16 tag.
>=20
> But kernel.org shows version 3.18 released.  I did some quick
> investigation and it looks like the v3.18 tag points to a dangling
> commit that is not on a branch.
>=20
> $ git log --graph --oneline v3.18 |head -n5
> * ba9a11a Release version 3.18.
> * 1e8811a Fix build with musl by using more common typedefs
> * 99bc878 bug fix: SFP Tx BIAS uses memory wrong offset
> * 4614098 Release version 3.16.
> * 14ef76c test-cmdline: Disable test cases for --rxfh hash key parsing
>=20
> $ git log --graph --oneline origin/master |head -n5
> * 4614098 Release version 3.16.
> * 14ef76c test-cmdline: Disable test cases for --rxfh hash key parsing
> * 86c0326 ethtool: Support for configurable RSS hash key
> * e633626 ethtool-copy.h: sync with net
> * 05b8ad5 Release version 3.14.
>=20
> Maybe you can merge the commits from your working branch back onto
> master and make another 3.18.1 tag or something.
>=20
> I just did:
> git checkout master
> git merge v3.18
>=20
> which worked okay, I think

Sorry about that, I pushed the tag but not the master branch when
releasing 3.18.  This should be fixed now.

There's a long weekend coming up, and I hope to get to the submitted
patches and make a 4.0 release then.

Ben.

--=20
Ben Hutchings
Lowery's Law:
             If it jams, force it. If it breaks, it needed replacing anyway=
.

--=-qLH4zezyZNcEDxS6SMTV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVR2JFue/yOyVhhEJAQpH2BAAgC2MGv9gK7KRab7LpJ2OddLL4sYoke9S
YPa0piv3iCeuVqxU/b0St/W0LHFtp0nyjfSUDv9gOJ2E9JK+u5fN53pM5cU7dxKp
dZPBzp5kwT/CWBLQOuE+Bbp43jVVPTI5iOEvgv5er+6sDLDjdUhugRS0kvT17xte
d41vOgYjPbdmEtvS0oArVNJ2U9GkrKWpLu0XCVH5tdYwXnh6+9E/T6lYeZ3qmk22
mqK6dNkwJZYgongn5WwgaRuQon3u5F5+53o/j1Cr4CNsXH7gPdh+pwnG431g2zkg
qsPBtUibjeypw1Lj0RNYmcFMhN/vNkpSbKoJKtkv6pR6V4bf7fqDwc8wEZ2UIc24
rshemY3UH787/udEEzQrmsNZq92RZ3Jlsl6EE17fm1f0TIIllQIChQ7vwvx+8c4s
nRf5BX6dD6HncViojEx7TyQOscko4KTy0Ej/acrN3yIGl/ogE7z0XMYncXVPwCSJ
yQd2GV98tmqgtPHLe8gd29IbJCBMuYRvPI6UQ4XBJv+Eyu8n1sw8fCuq6P0J88yY
ipCXvwL2KdCt4F4qSBBeEuc/wRzL5O1Qa92BGDuYTCt/jr1vZ54kIV3JVBKqAfn6
2mQREll8ze425aWeqCPS4h4k465wvlEXBzxFg6oBaaKmqSyWz6It49Qi2rctFORO
xMIsnbxxdSs=
=1+ni
-----END PGP SIGNATURE-----

--=-qLH4zezyZNcEDxS6SMTV--
