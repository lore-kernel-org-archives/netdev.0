From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: ixgbe: RTNL assertion failed
Date: Fri, 10 May 2013 05:36:13 +0100
Message-ID: <1368160573.17344.15.camel@deadeye.wl.decadent.org.uk>
References: <20130503120907.4f13d41b@nehalam.linuxnetplumber.net>
	 <F6FB0E698C9B3143BDF729DF222866464C28E112@ORSMSX110.amr.corp.intel.com>
	 <20130504015406.GP2619@decadent.org.uk>
	 <F6FB0E698C9B3143BDF729DF222866464C28E2AE@ORSMSX110.amr.corp.intel.com>
	 <1367702492.5106.164.camel@deadeye.wl.decadent.org.uk>
	 <20130506075828.717864ba@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-gipHKHEnaL3tqyHUsQgP"
Cc: "Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:55715 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750699Ab3EJEgS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 May 2013 00:36:18 -0400
In-Reply-To: <20130506075828.717864ba@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-gipHKHEnaL3tqyHUsQgP
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2013-05-06 at 07:58 -0700, Stephen Hemminger wrote:
> On Sat, 04 May 2013 22:21:32 +0100
> Ben Hutchings <ben@decadent.org.uk> wrote:
>=20
> > On Sat, 2013-05-04 at 21:05 +0000, Skidmore, Donald C wrote:
> > [...]
> > > > The version of ixgbe in this Debian kernel has bql support backport=
ed, but is
> > > > otherwise the same as in 3.2.41.  I assume that this bug has been f=
ixed some
> > > > time between 3.2 and 3.9, but no-one requested that the fix be incl=
uded in
> > > > stable branches.  Please can you identify the fix?
> > > >=20
> > > > Ben.
> > > >=20
> > > > --
> > > > Ben Hutchings
> > > > We get into the habit of living before acquiring the habit of think=
ing.
> > > >                                                               - Alb=
ert Camus
> > >=20
> > > I believe this is the patch:
> > >=20
> > > commit 34948a947d1a576c10afee6d14792fd237549577
> > > Author: Benjamin Poirier <bpoirier@suse.de>
> > > Date:   Fri Apr 6 07:20:21 2012 +0000
> > >=20
> > >     ixgbe: add missing rtnl_lock in PM resume path
> > [...]
> >=20
> > Looks like it.  And it applies cleanly to 3.2.y.  Stephen, could you
> > test this on top of 3.2.y and then nominate it for stable?
> >=20
> > Ben.
> >=20
>=20
> Patch works.
> Tested with 3.2.44 with this patch and there is no problem.

Thanks, I've added this to my queue.

Ben.

--=20
Ben Hutchings
For every action, there is an equal and opposite criticism. - Harrison

--=-gipHKHEnaL3tqyHUsQgP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUYx5Pee/yOyVhhEJAQpcYA/7B/KGuqa6Z9+KMXJeBbPxFpF4qbLw3KIH
Ab42TxsXEJwaVwNg9O+Xp8pRXekheFc/X4maOLd+Neq6b/UWu/D1i13kIQzVeZpA
IWRRQCNlZNSd0vmZSzNXPBGvCgl5eCPeAbrJ/SZ6aWwzJU47H5O0q1D8f2nQvVNl
LZvG8ZPTqYdkY1UsIJuXlyV+pzEEEfyeZQXldEq+riCZ7bf8uW5Y1dE9MLYyeR31
B/4s5Irz0YzMD0nw4h6uNV32QJ++c7ZIeJrHLur9gB5gchhhpKbBhN3k40Z0n+63
isLuRIr4WGPSSLqu1cpzpPEqfbRssRhGMPE8qwILyHA4v1tVak5cjzMMbeTjZamG
PfMI6EX7Kr1a/HA+7IkmCvrVXJdZIIOBqO1O01cQ3hCbuuqTqHDNgzm3UV7cduOk
tPinjxlc80Mfw5ljPaHToDwLP49uea6GGVge/ayVVY2zVFzxa6sY2lKNjne2OPZZ
gPU+Rg99w7MvQgCh9c6KoVpmJg2We7UV8gwylxgVNNUpcF5Zi1B75W1QwxKLfR62
MBHmOAsMcMiOW8sGINWVvdfNWblRak0J1gaa3NW7qb3pl3nbxP/RWo09WH5jtzjr
AFS7GUP96f2MrNeWs9WJAfKCX/sHSVBx246hsi6NDUId2OSSbwE5+Nk5uuRHdt9p
fkhq/Bser0s=
=jTTC
-----END PGP SIGNATURE-----

--=-gipHKHEnaL3tqyHUsQgP--
