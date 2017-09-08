From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [Intel-wired-lan] [PATCH] e1000e: changed some expensive calls
 of udelay to usleep_range
Date: Fri, 8 Sep 2017 11:28:27 +0200
Message-ID: <20170908092827.GC18365@amd>
References: <1503503985-3869-1-git-send-email-matthew.tan_1@nxp.com>
 <20170904162555.GB21849@amd>
 <309B89C4C689E141A5FF6A0C5FB2118B8C69E5E5@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="TiqCXmo5T1hvSQQg"
Cc: Matthew Tan <matthew.tan_1@nxp.com>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "michael.kardonik@nxp.com" <michael.kardonik@nxp.com>,
        "Williams, Mitch A" <mitch.a.williams@intel.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Brown, Aaron F" <aaron.f.brown@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <309B89C4C689E141A5FF6A0C5FB2118B8C69E5E5@ORSMSX101.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--TiqCXmo5T1hvSQQg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu 2017-09-07 22:19:47, Brown, Aaron F wrote:
> > From: Intel-wired-lan [mailto:intel-wired-lan-bounces@osuosl.org] On
> > Behalf Of Pavel Machek
> > Sent: Monday, September 4, 2017 9:26 AM
> > To: Matthew Tan <matthew.tan_1@nxp.com>
> > Cc: michael.kardonik@nxp.com; Williams, Mitch A
> > <mitch.a.williams@intel.com>; linux-kernel@vger.kernel.org;
> > john.ronciak@intel.com; intel-wired-lan@lists.osuosl.org;
> > netdev@vger.kernel.org
> > Subject: Re: [Intel-wired-lan] [PATCH] e1000e: changed some expensive c=
alls
> > of udelay to usleep_range
> >=20
> > Hi!
> >=20
> > > @@ -183,7 +183,7 @@ s32 e1000e_read_phy_reg_mdic(struct e1000_hw
> > *hw, u32 offset, u16 *data)
> > >  	 * reading duplicate data in the next MDIC transaction.
> > >  	 */
> > >  	if (hw->mac.type =3D=3D e1000_pch2lan)
> > > -		udelay(100);
> > > +		usleep_range(90, 100);
> > >
> > >  	return 0;
> > >  }
> >=20
> > Can you explain why shortening the delay is acceptable here?
>=20
> Maybe it's not.
>=20
> This patch is causing speed / duplex tests to fail on several of my test =
systems.  Specifically a Lenova laptop with an 82577 and a NUC with an i218=
 (though that does not mean it is limited to those or that it's not related=
 to the individual link partner.)
>

Ok, this should be quite easy to verify -- just adjust all the ranges
to be >=3D original ones.

Thanks,
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--TiqCXmo5T1hvSQQg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlmyYrsACgkQMOfwapXb+vJtVwCglW6IjPs++1mpDQHFpMW1ka7z
pnYAoLy0d7m1QYYLnfpwMhHgqs+8QP1w
=uwnL
-----END PGP SIGNATURE-----

--TiqCXmo5T1hvSQQg--
