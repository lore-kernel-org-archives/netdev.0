From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] DSA support for Micrel KSZ8895
Date: Fri, 1 Sep 2017 14:15:06 +0200
Message-ID: <20170901121506.GA32169@amd>
References: <20170816075524.GA18532@amd>
 <20170816140451.GA13006@lunn.ch>
 <9235D6609DB808459E95D78E17F2E43D40AFF8C1@CHN-SV-EXMX02.mchp-main.com>
 <20170827123658.GA727@amd>
 <20170827163122.GG13622@lunn.ch>
 <20170828070232.GA18135@amd>
 <20170828140927.GD10418@lunn.ch>
 <20170829074547.GB31303@amd>
 <93AF473E2DA327428DE3D46B72B1E9FD4111FA48@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="M9NhX3UHpAaciwkO"
Cc: Woojung.Huh@microchip.com, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        andrew@lunn.ch
To: Tristram.Ha@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD4111FA48@CHN-SV-EXMX02.mchp-main.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--M9NhX3UHpAaciwkO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

On Wed 2017-08-30 21:32:07, Tristram.Ha@microchip.com wrote:
> > On Mon 2017-08-28 16:09:27, Andrew Lunn wrote:
> > > > I may be confused here, but AFAICT:
> > > >
> > > > 1) Yes, it has standard layout when accessed over MDIO.
> > >
> > >
> > > Section 4.8 of the datasheet says:
> > >
> > > 	All the registers defined in this section can be also accessed
> > > 	via the SPI interface.
> > >
> > > Meaning all PHY registers can be access via the SPI interface. So you
> > > should be able to make a standard Linux MDIO bus driver which performs
> > > SPI reads.
> >=20
> > As far as I can tell (and their driver confirms) -- yes, all those regi=
sters can be
> > accessed over the SPI, they are just shuffled around... hence MDIO
> > emulation code. I copied it from their code (see the copyrights) so no,=
 I don't
> > believe there's nicer solution.
> >=20
> > Best regards,
>=20
> Can you hold on your developing work on KSZ8895 driver?  I am afraid your=
 effort may be in vain.  We at Microchip are planning to release DSA driver=
s for all KSZ switches, starting at KSZ8795, then KSZ8895, and KSZ8863.
>

Well, thanks for heads up... but its too late to stop now. I already
have working code, without the advanced features.

I don't know how far away you are with the development. You may want
to start from my driver (but its probably too late now).

> The driver files all follow the structures of the current KSZ9477 DSA dri=
ver, and the file tag_ksz.c will be updated to handle the tail tag of diffe=
rent chips, which requires including the ksz_priv.h header.  That is requir=
ed nevertheless to support using the offload_fwd_mark indication.
>=20
> The KSZ8795 driver will be submitted after Labor Day (9/4) if
> testing reveals no problem.  The KSZ8895 driver will be submitted
> right after that.  You should have no problem using the driver right
> away.

Well, normally world can help with the testing, too. It would be nice
to see the code, as [RFC]. There's great chance that you'll have to
modify the code to adress review feedback, which is why seeing code
soon is useful.

Best regards,
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--M9NhX3UHpAaciwkO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlmpT0oACgkQMOfwapXb+vIefACfedeQ1Ng+BhSoc+ScEFDnYjZf
kGUAn1QcG2Ocxcy2XakSs5GMtJzUunwB
=hXQl
-----END PGP SIGNATURE-----

--M9NhX3UHpAaciwkO--
