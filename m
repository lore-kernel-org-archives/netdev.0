From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 11/13] igb: Make Tx budget for NAPI user adjustable
Date: Mon, 19 Sep 2011 16:36:29 -0700
Message-ID: <1316475390.2184.8.camel@jtkirshe-mobl>
References: <4E776441.9090602@intel.com>
	 <1316448352.2764.27.camel@bwh-desktop>	<4E776E92.6090303@intel.com>
	 <20110919.170033.344802441047363137.davem@davemloft.net>
	 <4E77C1D4.503@intel.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-MKJmJ3+9x01L2WoQgQCs"
Cc: David Miller <davem@davemloft.net>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:13803 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750901Ab1ISXgo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Sep 2011 19:36:44 -0400
In-Reply-To: <4E77C1D4.503@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-MKJmJ3+9x01L2WoQgQCs
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2011-09-19 at 15:27 -0700, Duyck, Alexander H wrote:
> On 09/19/2011 02:00 PM, David Miller wrote:
> > From: Alexander Duyck<alexander.h.duyck@intel.com>
> > Date: Mon, 19 Sep 2011 09:32:18 -0700
> >> The fact is ixgbe has been using this parameter this way for over 2
> >> years now and the main goal of this patch was just to synchronize how
> >> things work on igb and ixgbe.
> >>
> >> Our hardware doesn't have a mechanism for firing an interrupt after X
> >> number of frames so instead we simply have modified things so that we
> >> will only process X number of frames and then fire another
> >> interrupt/poll if needed.  As such we aren't that far out of
> >> compliance with the meaning of how this parameter is supposed to be
> >> used.
> > All I can say is this was a huge mistake you therefore need to revert
> > the IXGBE change, these ethtool settings are not for changing NAPI or
> > software interrupt behavior.
> >
> > And if you guys plan to be difficult on this and refuse to remove the
> > IXGBE bits, I'm letting you guys know ahead of time that I'll do it
> > for you.
> >
> > If the hardware can't support this facility, neither should these
> > ethtool hooks, because the whole point is to avoid hardware interrupts
> > from firing using these parameters.
> >
> > Propose new mechanisms to control NAPI behavior if you want.
> I'll remove the ixgbe code if that is what you want.  It may be a month=
=20
> or so before I can get to it though since I am slammed with work so if=
=20
> you are in a hurry for it you might want to work with Jeff Kirsher to=20
> have the code removed.

Alex- I will work on this to resolve the issues the Ben and Dave have
pointed out.

>=20
> As far as this current patch goes I honestly don't have the time to add=
=20
> or rewrite yet another ethtool interface so I will probably just see=20
> about dropping the ethtool portion of this patch and update the=20
> description in order to make it acceptable.
>=20
> Thanks,
>=20
> Alex



--=-MKJmJ3+9x01L2WoQgQCs
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOd9H9AAoJECTsCADr/EWUzXoH/iBZ84VtUYWKYrJATeci8G0l
oMZCFRbnA8QieypW1ymPF1rRw3RbgZEre6rrZe+44J7pH74SLDK3mLSzae0V+v8E
xXqPKOsx6gxos72djdTupo+0WGq52pO+/l8Kty50HNng7nxTawHN2Zmi+w7Hqdjd
TIlr7nVdSRxD3JJMXdeBFZGwZRHGs/s5bRx8tcbsnsJLJprBEMtpjAm9MEpfCzYG
TuWEIaG2uVHLWPjypQgxKuv8M8bguSB+mBTPBN2Za0zHgOcCuqV7A8uJwa4Ld+uR
jPuGk+N3fke4q2HNB6qulUS6buIqgKGfD3MW/NImlCfzcZExHSwO3yoOgNGWd8o=
=bAHc
-----END PGP SIGNATURE-----

--=-MKJmJ3+9x01L2WoQgQCs--
