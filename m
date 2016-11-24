From: Sebastian Reichel <sre@kernel.org>
Subject: Re: wl1251 & mac address & calibration data
Date: Thu, 24 Nov 2016 16:13:17 +0100
Message-ID: <20161124151317.34yoza3dzuh46oa4@earth>
References: <201611111820.52072@pali>
 <201611221805.13606@pali>
 <20161123222335.GA4788@amd>
 <201611232339.59411@pali>
 <20161124075104.GA26721@amd>
 <20161124083329.GB13735@pali>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="6hqdupe46ykut2ut"
Cc: Pavel Machek <pavel@ucw.cz>,
        Michal Kazior <michal.kazior@tieto.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Tony Lindgren <tony@atomide.com>,
        linux-wireless <linux-wireless@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        linux-kernel@vger.kernel.org
To: Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:56258 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965842AbcKXPPg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Nov 2016 10:15:36 -0500
Content-Disposition: inline
In-Reply-To: <20161124083329.GB13735@pali>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--6hqdupe46ykut2ut
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Thu, Nov 24, 2016 at 09:33:29AM +0100, Pali Roh=C3=A1r wrote:
> On Thursday 24 November 2016 08:51:04 Pavel Machek wrote:
> > Hi!
> >=20
> > > > "ifconfig hw ether XX" normally sets the address. I guess that's
> > > > ioctl?
> > >=20
> > > This sets temporary address and it is ioctl. IIRC same as what ethtoo=
l=20
> > > uses. (ifconfig is already deprecated).
> > >=20
> > > > And I guess we should use similar mechanism for permanent
> > > > address.
> > >=20
> > > I'm not sure here... Above ioctl =E2=86=91=E2=86=91=E2=86=91 is for c=
hanging temporary mac=20
> > > address. But here we do not want to change permanent mac address. We=
=20
> > > want to tell kernel driver current permanent mac address which is
> > > stored
> >=20
> > Well... I'd still use similar mechanism :-).
>=20
> Thats problematic, because in time when wlan0 interface is registered
> into system and visible in ifconfig output it already needs to have
> permanent mac address assigned.
>=20
> We should assign permanent mac address before wlan0 of wl1251 is
> registered into system.

You can just add the MAC address to the NVS data, which is also
required for the device initialization.

I wonder if those information could be put into DT. Iirc some
network devices get their MAC address from DT. Maybe we can add
all NVS info to DT? How much data is it?

Userspace application can add all those information to the DT
using a DT overlay. Also the u-boot could parse and add it at
some point in the future.

-- Sebastian

--6hqdupe46ykut2ut
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEE72YNB0Y/i3JqeVQT2O7X88g7+poFAlg3A4kACgkQ2O7X88g7
+povvg//ag54t+LwzgNFcz4vf8XT2HmiBxreOCW4pehhTugDXURt05Z6gCQA5Smb
f+1aB4SyyG+KcZHVnrryOq1OYTMSASjYCu/kUrjnynGRapyGBvTAJMUwsGAdaexV
UWyPxV3ph/3D17CUBXuo95bE+vAX0KK01U9mY9RVcaWHlSrdlj4RRJTKb/okMDN7
tX+eiK5/lAeHz+Y2eiNlMuIKkuO4IGqEGo+WcCnGUK6VRw2q1YqWYhjmTlXawQC7
OUw2luZhDSSnuErvbcM4QugA8uTUq67ZfBocH9CHr3to/AvPkC4taKAUJRo7w7mG
5mDaymLDsxHMemZX/7vwTbX/haKQHMIVAXBCz2QWa2dvbsA+vMgLu1Bwvh2IpBF/
W3KLQJY7BWMWia2sz0qj4f57s66Upw6deaU7vcfFcOCtCy8DVpD+yMwne8NI5esx
18QAqz05hInQcH4VXCwd5ZIhKyZyss31TDy8UkoMZZW24x7XYVNzZxPM/aeu9qx5
1qB+BNlrgtK1Vg9J0epn0sYSsxbKIaAtMu1wYJSMK2dHlcoIXurhyJjps960eh9c
HJiZhrlZeK3aOSCinI5yGT1prtbhYb7n1fFv62VTkmUzZlED3A1lM0LPrhH6SGwr
d1eR70kprmFX9i9dREGfDuw7bAtRgokap119VpCuh5JZEQlbybQ=
=7qNW
-----END PGP SIGNATURE-----

--6hqdupe46ykut2ut--
