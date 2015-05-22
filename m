From: Marek =?utf-8?Q?Marczykowski-G=C3=B3recki?=
	<marmarek@invisiblethingslab.com>
Subject: Re: [Xen-devel] xen-netfront crash when detaching network while some
 network activity
Date: Fri, 22 May 2015 18:42:46 +0200
Message-ID: <20150522164246.GE957@mail-itl>
References: <20150522114932.GC8664@mail-itl>
 <555F5888.4020303@citrix.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="SlnaBQtdWG0gYnqZ"
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	netdev@vger.kernel.org, xen-devel <xen-devel@lists.xen.org>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:43130 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756920AbbEVQmx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 12:42:53 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id B5C1120B4E
	for <netdev@vger.kernel.org>; Fri, 22 May 2015 12:42:52 -0400 (EDT)
Content-Disposition: inline
In-Reply-To: <555F5888.4020303@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--SlnaBQtdWG0gYnqZ
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, May 22, 2015 at 05:25:44PM +0100, David Vrabel wrote:
> On 22/05/15 12:49, Marek Marczykowski-G=C3=B3recki wrote:
> > Hi all,
> >=20
> > I'm experiencing xen-netfront crash when doing xl network-detach while
> > some network activity is going on at the same time. It happens only when
> > domU has more than one vcpu. Not sure if this matters, but the backend
> > is in another domU (not dom0). I'm using Xen 4.2.2. It happens on kernel
> > 3.9.4 and 4.1-rc1 as well.
> >=20
> > Steps to reproduce:
> > 1. Start the domU with some network interface
> > 2. Call there 'ping -f some-IP'
> > 3. Call 'xl network-detach NAME 0'
>=20
> I tried this about 10 times without a crash.  How reproducible is it?
>=20
> I used a 4.1-rc4 frontend and a 4.0 backend.

It happens every time for me... Do you have at least two vcpus in that
domU? With one vcpu it doesn't crash. The IP for ping I've used one in
backend domU, but it shouldn't matter.

Backend is 3.19.6 here. I don't see any changes there between rc1 and
rc4, so stayed with rc1. With 4.1-rc1 backend it also crashes for me.

--=20
Best Regards,
Marek Marczykowski-G=C3=B3recki
Invisible Things Lab
A: Because it messes up the order in which people normally read text.
Q: Why is top-posting such a bad thing?

--SlnaBQtdWG0gYnqZ
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJVX1yGAAoJENuP0xzK19csWIMH/jsdxAHcxiCQnotxp3RBM9qr
cOvodC4zhMczEgFAaPui+PWguODLyRxV/XJYiSnEIYJUFJCMV/Z+b9/yZLCdpq1G
A7qRRBuRYQvFHAPyURpAzaP2oRAZ5qbP1xP2E/YaDboxjWdB1joQBmNz23xfn/l7
0vupsynBqRgUk3vS3Z9Nvs438RSxuIIMSwpMFV+I87/4myv1TvfFbMNJArRLfx6o
Mb7SFq8JA0NYHyybvXED0H91sNIlR4a9S25BB8TWeR4KSI/QpApEGhDFwP5e0I4X
Y0Z9+nBbARonbvbVRrwDFYS228vwbNSaFxaZ/8cLSd93O2e8a5JBAPKrJwciOrs=
=Nj6H
-----END PGP SIGNATURE-----

--SlnaBQtdWG0gYnqZ--
