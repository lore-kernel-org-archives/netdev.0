From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] DSA support for Micrel KSZ8895
Date: Sat, 2 Sep 2017 17:40:14 +0200
Message-ID: <20170902154014.GA21453@amd>
References: <20170816140451.GA13006@lunn.ch>
 <9235D6609DB808459E95D78E17F2E43D40AFF8C1@CHN-SV-EXMX02.mchp-main.com>
 <20170827123658.GA727@amd>
 <20170827163122.GG13622@lunn.ch>
 <20170828070232.GA18135@amd>
 <20170828140927.GD10418@lunn.ch>
 <20170829074547.GB31303@amd>
 <93AF473E2DA327428DE3D46B72B1E9FD4111FA48@CHN-SV-EXMX02.mchp-main.com>
 <20170901121506.GA32169@amd>
 <16a7fede-d308-f759-9444-22e754903612@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="gKMricLos+KVdGMg"
Cc: Tristram.Ha@microchip.com, Woojung.Huh@microchip.com,
        nathan.leigh.conrad@gmail.com, vivien.didelot@savoirfairelinux.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        andrew@lunn.ch
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <16a7fede-d308-f759-9444-22e754903612@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--gKMricLos+KVdGMg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> >>>> Section 4.8 of the datasheet says:
> >>>>
> >>>> 	All the registers defined in this section can be also accessed
> >>>> 	via the SPI interface.
> >>>>
> >>>> Meaning all PHY registers can be access via the SPI interface. So you
> >>>> should be able to make a standard Linux MDIO bus driver which perfor=
ms
> >>>> SPI reads.
> >>>
> >>> As far as I can tell (and their driver confirms) -- yes, all those re=
gisters can be
> >>> accessed over the SPI, they are just shuffled around... hence MDIO
> >>> emulation code. I copied it from their code (see the copyrights) so n=
o, I don't
> >>> believe there's nicer solution.
> >>>
> >>> Best regards,
> >>
> >> Can you hold on your developing work on KSZ8895 driver?  I am afraid y=
our effort may be in vain.  We at Microchip are planning to release DSA dri=
vers for all KSZ switches, starting at KSZ8795, then KSZ8895, and KSZ8863.
> >>
> >=20
> > Well, thanks for heads up... but its too late to stop now. I already
> > have working code, without the advanced features.
>=20
> No driver has landed yet nor has any driver been posted in a proper form
> or shape, so at this point neither of you are able to make any claims as
> to which one should be chosen.

I certainly do not want to make any claims. Tristram's driver is
likely to support all (most?) features of the chip, which is not my
goal.

> > I don't know how far away you are with the development. You may want
> > to start from my driver (but its probably too late now).
>=20
> I would tend to favor Tristram's submission when we see it because he
> claims support for more devices and it is likely to be backed and
> maintained by Microchip in the future.

Well, I guess we decide when we see the code, that's how it works, right?

> I am sure there will be opportunity for you to contribute a lot to this
> driver. Of course, this all depends on the code quality and timing, but
> having two people work on the same things in parallel is just a complete
> waste of each other's time so we might as well wait for Tristram to post
> the said driver and define a plan of action from there?

Well, it would be good to see the code, so we can judge the
quality. Normally, code is posted before testing, so this kind of
problems does not arise.

Best regards,

									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--gKMricLos+KVdGMg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlmq0N4ACgkQMOfwapXb+vKnfACgvK+kPCY1eIfaWpd3FSImlSkq
8BgAoKt5HA6UJIcrqsC8iiCEyPOrPMg+
=S7bb
-----END PGP SIGNATURE-----

--gKMricLos+KVdGMg--
