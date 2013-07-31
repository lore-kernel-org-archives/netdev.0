From: Felipe Balbi <balbi@ti.com>
Subject: Re: [net-next PATCH 1/1] drivers: net: cpsw: Add support for new
 CPSW IP version
Date: Wed, 31 Jul 2013 22:43:32 +0300
Message-ID: <20130731194332.GA900@radagast>
References: <1375272746-24446-1-git-send-email-mugunthanvnm@ti.com>
 <20130731144957.GC4904@netboy>
 <20130731152827.GB25618@radagast>
 <20130731163845.GB4234@netboy>
 <20130731184525.GA629@radagast>
 <20130731192229.GB8027@netboy>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="FL5UXtIhxfXey3p5"
Cc: Felipe Balbi <balbi@ti.com>, Mugunthan V N <mugunthanvnm@ti.com>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>,
	<linux-omap@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:57126 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754425Ab3GaTnq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jul 2013 15:43:46 -0400
Content-Disposition: inline
In-Reply-To: <20130731192229.GB8027@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--FL5UXtIhxfXey3p5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Wed, Jul 31, 2013 at 09:22:29PM +0200, Richard Cochran wrote:
> On Wed, Jul 31, 2013 at 09:45:25PM +0300, Felipe Balbi wrote:
> > On Wed, Jul 31, 2013 at 06:38:46PM +0200, Richard Cochran wrote:
> > > On Wed, Jul 31, 2013 at 06:28:27PM +0300, Felipe Balbi wrote:
> > > > On Wed, Jul 31, 2013 at 04:49:59PM +0200, Richard Cochran wrote:
> > > > > On Wed, Jul 31, 2013 at 05:42:26PM +0530, Mugunthan V N wrote:
> > > > > > The new IP version has a minor changes and the offsets are same=
 as the previous
> > > > > > version, so instead of adding CPSW version number in the driver=
, make the driver
> > > > > > to fall through to the latest versions so that the new version =
of CPSW which has
> > > > > > the same register offsets will work directly without patching t=
he driver.
> > > > >=20
> > > > > This doesn't make any sense to me. Why not just add the new versi=
on
> > > > > number?
> > > > >=20
> > > > > None of the hunks in your patch are on performance sensitive path=
s, so
> > > > > I really can't see any point in removing the error checking.
> > > >=20
> > > > well, if a new revision of the IP comes, the driver at least has so=
me
> > > > chance to work without having to be modified. If it turns out that =
there
> > > > are really different features, then we patch a new version, otherwi=
se we
> > > > should just assume highest known version and try it out.
> > >=20
> > > And if the driver reads junk from some random address due to
> > > bootloader/DT/multikernel madness, it will happily peek and poke
> > > around instead of rejecting the wrong version number.
> >=20
> > that'd be a bug in the DT anyway, why should the driver have to cope
> > with broken data ?
>=20
> Um, it is called error checking?

right, now go check on the archives what Linus (and many others, for
that matter) have said about version checking. If it's not the version
you expect, you assume the latest.

Imagine the situation where new IP version has new features, but all the
others still work and we don't use that new feature. We'd have to patch
the kernel just to get the driver to probe() even though the entire
driver is still 'compliant' with the new IP.

> Besides, by not checking the version number, you are pre-programming a
> disaster that will occur when an older kernel is booted on the first
> new IP version with important changes. Can you really be sure that all
> users will have the new, patched kernel?

why will there be a disaster ?

--=20
balbi

--FL5UXtIhxfXey3p5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJR+WjkAAoJEIaOsuA1yqRE+8cQALCJu9PytzBtZAnBwC3EzXck
IzOvFlj86k1Yr0W75gW+U1AWZ2dpJSipDv71KdregSSKTYjCeObIx/ZLpBZAqOaY
K4/O6qWcN7rSZJqmYTZx3yFIBjKxn41m1+Z9RgqznJ5rkEVN0kMOsDoQOB6QFmfS
1Ap5YUVWcZtXwouNi4Z/bcGLYbMP7eYYJWzdm0irxiu5aIeLB2u3qxZN8Yb+Y3R/
ZoXmgFlliTnzx3pcX3zBCylJ5tedXln3CZMyDkggjS0bqv2VjU7GyV4F2xljfDe3
MxUkVfqvdLYct3dE+/4Ri+seph1nnNVlt6PCyA3b3p3zAvl6iZrwLe+16CAmJWYG
nqRhPz4MtSnySnlqZtJp+PMCYtg3ErP/op3uBlwPPpqklZngTYLNI814ZN/BF1Gk
nhC8cxUHzF9v+Hlh7d18rbf0oTKQ7YXzFXfe1TsejWCZTYMlkvZ4tkLDu7OazJs+
avAClshf4u8umIcPVPx14vRUMmZ4lPc1NBo+583UgLEgMK64YgjDEAS5vtQgtRqt
pYeXuYPqyBBcHPATKvnarEoz1lIIESOfAf/WwyMJSvNwhFTm1Ec4n3Fgbtm9VvdR
FsC7TYz3Z6LjDSnWU5CjUEDy8buCo620qyBQ1wl9UxbNjxkF7qye6ViJm1exKxOH
W/SAo9vz8e4XZn8v6SYb
=yaTH
-----END PGP SIGNATURE-----

--FL5UXtIhxfXey3p5--
