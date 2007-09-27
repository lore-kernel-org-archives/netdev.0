From: Jochen Voss <voss@seehuhn.de>
Subject: Re: [PATCH] sky2: sky2 FE+ receive status workaround
Date: Thu, 27 Sep 2007 16:23:29 +0100
Message-ID: <20070927152317.GB12271@seehuhn.de>
References: <20070926175847.706025d0@freepuppy.rosehill> <4C6E8545-ADDC-456E-B17B-B3512A6047D1@seehuhn.de> <20070927065807.7a71ae89@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="B4IIlcmfBL/1gGOG"
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from seehuhn.de ([80.68.93.199]:3576 "EHLO seehuhn.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755501AbXI0PXn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Sep 2007 11:23:43 -0400
Content-Disposition: inline
In-Reply-To: <20070927065807.7a71ae89@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--B4IIlcmfBL/1gGOG
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Thu, Sep 27, 2007 at 06:58:07AM -0700, Stephen Hemminger wrote:
> On Thu, 27 Sep 2007 09:14:11 +0100 Jochen Vo=DF <voss@seehuhn.de> wrote:
> > On 27 Sep 2007, at 01:58, Stephen Hemminger wrote:
> > > +	/* This chip has hardware problems that generates bogus status.
> > > +	 * So do only marginal checking and expect higher level protocols
> > > +	 * to handle crap frames.
> > > +	 */
> > > +	if (sky2->hw->chip_id =3D=3D CHIP_ID_YUKON_FE_P &&
> > > +	    sky2->hw->chip_rev =3D=3D CHIP_REV_YU_FE2_A0 &&
> > > +	    length !=3D count)
> > > +		goto okay;
> >=20
> > Shouldn't the condition be "length =3D=3D count"?
>=20
> No, the code is correct as is.  Basically if length =3D=3D count, then
> the status field is correct, and the driver can go ahead and use it.
> If length !=3D count, then the status is bogus but the data is okay.

Oh, I see.  Thanks for the explanation.

All the best,
Jochen
--=20
http://seehuhn.de/

--B4IIlcmfBL/1gGOG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFG+8rxf+iD8yEbECURAhfGAJ9ofuzST0y7JaUgZY82GIcpOcKhswCdGhSn
DzTYKBPluRwGBonQORZN/bo=
=Tsvo
-----END PGP SIGNATURE-----

--B4IIlcmfBL/1gGOG--
