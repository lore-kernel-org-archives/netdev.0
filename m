From: Marek =?utf-8?Q?Marczykowski-G=C3=B3recki?=
	<marmarek@invisiblethingslab.com>
Subject: Re: xen-netfront crash when detaching network while some network
 activity
Date: Tue, 1 Dec 2015 23:32:58 +0100
Message-ID: <20151201223258.GH1337@mail-itl>
References: <20150522114932.GC8664@mail-itl>
 <55645140.1050209@citrix.com>
 <20150526220312.GA1358@mail-itl>
 <20151021185734.GD31646@mail-itl>
 <20151117024515.GN976@mail-itl>
 <20151201220042.GC22107@char.us.oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="hYooF8G/hrfVAmum"
Cc: David Vrabel <david.vrabel@citrix.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Annie Li <annie.li@oracle.com>,
	xen-devel <xen-devel@lists.xen.org>, netdev@vger.kernel.org
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:56635 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756879AbbLAWdG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 17:33:06 -0500
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 9728520791
	for <netdev@vger.kernel.org>; Tue,  1 Dec 2015 17:33:05 -0500 (EST)
Content-Disposition: inline
In-Reply-To: <20151201220042.GC22107@char.us.oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--hYooF8G/hrfVAmum
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Dec 01, 2015 at 05:00:42PM -0500, Konrad Rzeszutek Wilk wrote:
> On Tue, Nov 17, 2015 at 03:45:15AM +0100, Marek Marczykowski-G=C3=B3recki=
 wrote:
> > On Wed, Oct 21, 2015 at 08:57:34PM +0200, Marek Marczykowski-G=C3=B3rec=
ki wrote:
> > > On Wed, May 27, 2015 at 12:03:12AM +0200, Marek Marczykowski-G=C3=B3r=
ecki wrote:
> > > > On Tue, May 26, 2015 at 11:56:00AM +0100, David Vrabel wrote:
> > > > > On 22/05/15 12:49, Marek Marczykowski-G=C3=B3recki wrote:
> > > > > > Hi all,
> > > > > >=20
> > > > > > I'm experiencing xen-netfront crash when doing xl network-detac=
h while
> > > > > > some network activity is going on at the same time. It happens =
only when
> > > > > > domU has more than one vcpu. Not sure if this matters, but the =
backend
> > > > > > is in another domU (not dom0). I'm using Xen 4.2.2. It happens =
on kernel
> > > > > > 3.9.4 and 4.1-rc1 as well.
> > > > > >=20
> > > > > > Steps to reproduce:
> > > > > > 1. Start the domU with some network interface
> > > > > > 2. Call there 'ping -f some-IP'
> > > > > > 3. Call 'xl network-detach NAME 0'
>=20
> Do you see this all the time or just on occassions?

Using above procedure - all the time.

> I tried to reproduce it and couldn't see it. Is your VM an PV or HVM?

PV, started by libvirt. This may have something to do, the problem didn't
existed on older Xen (4.1) and started by xl. I'm not sure about kernel
version there, but I think I've tried there 3.18 too, which has this
problem.

But I don't see anything special in domU config file (neither backend
nor frontend) - it may be some libvirt default. If that's really the
cause. Can I (and how) get any useful information about that?


--=20
Best Regards,
Marek Marczykowski-G=C3=B3recki
Invisible Things Lab
A: Because it messes up the order in which people normally read text.
Q: Why is top-posting such a bad thing?

--hYooF8G/hrfVAmum
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJWXiAaAAoJENuP0xzK19csGeAH/18GMYK2gxEMpfFuFAO8i5f9
cKrVEeYg5tkcXHHd7h5sTg7J2hZuDiyxzkko5LCEJhIg7jF8Ox+trZGu9Ytsidin
NB9N24OYYSNeuZMiRUxSCY5DyYDodXP6HWp6fXPNdhXdWNr+gtCSAF4laruMYllJ
3Ls89SB6dtW3RkLzGD4xL2Bvvxlqh5x03Gv7Pyj2bXE5QGdHcWTfTJBPnblLK0rp
1SIL1LJhBDejzY4GrNpSI+i6qaygAoeMN0kltVzKDUBjsOQkFqC+NIt55CUXj1i1
BJt/bUYhDsWZ060WOfxk66WGxR5khdwWNe20bBraPlTPNQQXVjt1KM442xAmHmw=
=4zMa
-----END PGP SIGNATURE-----

--hYooF8G/hrfVAmum--
