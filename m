From: Ben Hutchings <ben@decadent.org.uk>
Subject: RE: [PATCH 1/2] linux-firmware: update firmware for RTL8111E
Date: Tue, 17 May 2011 03:39:47 +0100
Message-ID: <1305599987.19966.99.camel@localhost>
References: <1304928149-2201-1-git-send-email-hayeswang@realtek.com>
	 <1304929425.12237.15.camel@i7.infradead.org>
	 <20110509192309.GA20763@electric-eye.fr.zoreil.com>
	 <883AEB89D11D495A9666E2F73C2CD95F@realtek.com.tw>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512"; protocol="application/pgp-signature"; boundary="=-CGT9Su+mWutFtKon6epH"
Cc: 'Francois Romieu' <romieu@fr.zoreil.com>,
	'David Woodhouse' <dwmw2@infradead.org>, netdev@vger.kernel.org
To: hayeswang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:46707 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751839Ab1EQCj7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 22:39:59 -0400
In-Reply-To: <883AEB89D11D495A9666E2F73C2CD95F@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-CGT9Su+mWutFtKon6epH
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2011-05-10 at 10:09 +0800, hayeswang wrote:
>=20
> Francois Romieu [mailto:romieu@fr.zoreil.com]=20
> > Sent: Tuesday, May 10, 2011 3:23 AM
> > To: David Woodhouse
> > Cc: Hayeswang; netdev@vger.kernel.org
> > Subject: Re: [PATCH 1/2] linux-firmware: update firmware for RTL8111E
> >=20
> > David Woodhouse <dwmw2@infradead.org> :
> > [...]
> > > I'd be a lot happier if the WHENCE file contained version numbers.=
=20
> > > Does the *driver* print a version string for the firmware=20
> > after loading it?
> >=20
> > No.
> >=20
> > Hayes, do we agree that the firmware needs to embed a version=20
> > identifier (and some checksum to identify the current=20
> > firmware that don't embed one).
> >=20
>=20
> I agree that. However, I have no idea about making it compatible with pre=
vious
> parser and firmware. Let me think if there is a good way to do this.

A PHY_DATA_AND at the beginning of a firmware blob instruction is a
no-op, so you could use that to add version information in a compatible
way.  For RTL8168D, however, you are right that this would break
compatibility with the earlier driver versions that only handled
PHY_WRITE.

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-CGT9Su+mWutFtKon6epH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATdHf7ue/yOyVhhEJAQrL2A//a++PEWcBZclfe8B6uwPwzK8Wdo67E6mc
7D7mjrb5RivsnQCNxB48NMtRTpcacKNGMpe2aaEbSIah2oJE9QFoHuvC+9OKVgap
McWJhQNyp5WlRlTF459SV5zt3q090Y6PJi35OtY+loOZnUUnxdAyqSCyZPCfxXKd
FpRnwo5qewyilD/6vVIz+szJrR3tJng/a6nC10AsryHcvh81oUzDVAUO7jbjKA5O
Qqz4yeFt7jskhLAUTwuaahMOxzkv/GLQ1dJ67ovrJKVNKWM4h/DjHSoF9F/mmBlm
kZZ9Jdlr0XcMnd6eWxC+xQ95lkr8yWoxIpW4h8xdAdqJRpE16j3QREa0MxWB8/Fg
Au1j0qQiN/axRHDf2T/SZE+yByVs0pVJJlEtXXjZN1oBOSuCoiqGiHDcbtEi0d2m
oCFNcGGrUK1E2EIB8Yf9J2vz53W7v0BBP2/yRHhdWmr93gsMUHhQVgaJQyRtQwd3
93haqWl+Rf7KdK0/F5ePkyjaSDjPuxfXa2tuF7D3cannDiUk3eoIwJar1oVbcaYd
PDStYWZpOXexk4FDmEtMiDBRpZSQuj8EtWrOTx6mPRGK8LPKclqCio8ncdiwyQ6V
0b2DpdQKgV7IYqMmKJJAo6c5125jImwHNA4+PXwj/XUxYh3lPqPU8nz01DKXGJEL
8H70Hf1ZWbQ=
=pqlY
-----END PGP SIGNATURE-----

--=-CGT9Su+mWutFtKon6epH--
