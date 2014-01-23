From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next 3/4] ethtool: Support for configurable RSS hash
 key.
Date: Thu, 23 Jan 2014 15:09:16 +0000
Message-ID: <1390489756.1547.13.camel@deadeye.wl.decadent.org.uk>
References: <BF3270C86E8B1349A26C34E4EC1C44CB2C83D8E5@CMEXMB1.ad.emulex.com>
	 <1390156048.16433.114.camel@deadeye.wl.decadent.org.uk>
	 <BF3270C86E8B1349A26C34E4EC1C44CB2C84C327@CMEXMB1.ad.emulex.com>
	 <1390224028.3651.72.camel@deadeye.wl.decadent.org.uk>
	 <BF3270C86E8B1349A26C34E4EC1C44CB2C84CFAE@CMEXMB1.ad.emulex.com>
	 <1390455540.3651.136.camel@deadeye.wl.decadent.org.uk>
	 <BF3270C86E8B1349A26C34E4EC1C44CB2C84D71E@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Qc6B9jrG3jLjYUaut/c5"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:44443 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932082AbaAWPJa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 10:09:30 -0500
In-Reply-To: <BF3270C86E8B1349A26C34E4EC1C44CB2C84D71E@CMEXMB1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Qc6B9jrG3jLjYUaut/c5
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-01-23 at 13:47 +0000, Venkata Duvvuru wrote:
> > -----Original Message-----
> > From: Ben Hutchings [mailto:ben@decadent.org.uk]
> > Sent: Thursday, January 23, 2014 11:09 AM
> > To: Venkata Duvvuru
> > Cc: netdev@vger.kernel.org
> > Subject: Re: [PATCH net-next 3/4] ethtool: Support for configurable RSS=
 hash
> > key.
> >=20
> > On Wed, 2014-01-22 at 12:12 +0000, Venkata Duvvuru wrote:
> > [...]
> > > > No, what I mean is:
> > > >
> > > > 1. An RX flow steering filter can specify use of RSS, in which case
> > > > the value looked up in the indirection is added to the queue number
> > > > specified in the filter.  This is not yet controllable through RX
> > > > NFC though there is room for extension there.
> > > >
> > > > 2. Multi-function controllers need multiple RSS contexts (key +
> > > > indirection
> > > > table) to support independent use of RSS on each function.
> > > > But it may also be possible to allocate multiple contexts to a sing=
le
> > function.
> > > > This could be useful in conjunction with 1.  But there would need t=
o
> > > > be a way to allocate and configure extra contexts first.
> > > The proposed changes will be incremental so I think this can be done
> > > in a separate patch. Thoughts?
> >=20
> > The ethtool ABI (to userland) has to remain backward-compatible, and it=
 is
> > preferable if we don't add lots of different structures for this.
> >=20
> > So please define the new command structure to include both the key and
> > indirection table, and some reserved space (documented as 'userland mus=
t
> > set to 0') for future extensions.
>=20
> I think it=E2=80=99s better to keep key and indirection table settings as
> different ethtool commands. We can probably add rss contexts (reserved
> space) to both the command structures.
> If we mix key and indirection table into one command structure then it
> will hamper the compatibility.
[...]

Right, there is no compatible way to extend struct ethtool_rxfh_indir.
I should have thought ahead when defining it!  But the new structure
doesn't need to have that problem.

Ben.

--=20
Ben Hutchings
compatible: Gracefully accepts erroneous data from any source

--=-Qc6B9jrG3jLjYUaut/c5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIVAwUAUuEwnOe/yOyVhhEJAQrogg//djKvaD1BljAiOz/+v9TPmAY+ZHHonLLC
q6WtK7Jpb+PFusYMg3XjpgQfa2IbyFxLAcyazVNUDHjnRp8Q+FOlc98sA3xG6B55
KcZifWBBjQ08L/GpaJdR11xroH5+0+D+JaRc96HUxxmqDtrHqQGolCjFVbhE9uNI
taz4e44oYIbzmKTcG4ThOHLEKfgAp/4clZbS3vg3wkDoHdb1tRvd1JLvsJm42eud
mC8qRSvLSeqbKl4NDOvfSg7eQw0HVOx/9XLrNocFeSOfbcOg/VDpymNQFwaHqX9X
FXYjY2dWp7nRWLQ1EuhY8sljF2w1MWjXq0nghVlqSKHYoHhbZVyS8/nTfBdlOHrZ
BipBeuWdGRlgQWPMfTxyAiULpLuzWGXIyZ4whms+YfB5jVBfdFEwg57QRguZsrw1
21MqAfhI1wxJY6x1W/BRRnGRztgDHToQMHtH4Vt2Pqjsd+Pk7qP7bE2WVDhXEmms
S/wUqrNOUe8sNksjBlJiLLCO9IYPezcm1468EP/J6KtQmDK6bjBYY+ydyTfnN5ZA
ozOrAyF7+rbDlKRx4RHjCtruaJpGijzdS5xAHq6hNoQphZZoaVH8Mp0HvJWe8aR2
pYQepcx/HAR/SDCE/c7y5hjLgtHg1rVqcdtTI5LBcLI+s4YRucQijf+TWshiG/Ns
fG7kxubDPDU=
=9Aq/
-----END PGP SIGNATURE-----

--=-Qc6B9jrG3jLjYUaut/c5--
