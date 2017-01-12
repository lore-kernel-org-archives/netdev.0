From: Pavel Machek <pavel@ucw.cz>
Subject: Re: wl1251 & mac address & calibration data
Date: Thu, 12 Jan 2017 09:50:33 +0100
Message-ID: <20170112085033.GA27429@amd>
References: <201611111820.52072@pali>
 <201612181204.52928@pali>
 <83b2e9a4-f990-68a8-241e-375e46448d47@broadcom.com>
 <201612181309.01298@pali>
 <fd180271-1cd4-9891-e3d5-ae9cd0fb088b@broadcom.com>
 <87shpiu8j8.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="zYM0uCDKw75PZbzx"
Cc: Arend Van Spriel <arend.vanspriel@broadcom.com>,
        Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>,
        Daniel Wagner <wagi@monom.org>,
        "Luis R. Rodriguez" <mcgrof@kernel.org>,
        Tom Gundersen <teg@jklm.no>,
        Johannes Berg <johannes@sipsolutions.net>,
        Ming Lei <ming.lei@canonical.com>,
        Mimi Zohar <zohar@linux.vnet.ibm.com>,
        Bjorn Andersson <bjorn.andersson@linaro.org>,
        =?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
        Sebastian Reichel <sre@kernel.org>,
        Michal Kazior <michal.kazior@tieto.com>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Tony Lindgren <tony@atomide.com>,
        linux-wireless <linux-wireless@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vge
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87shpiu8j8.fsf@kamboji.qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--zYM0uCDKw75PZbzx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> >> But overwriting that one file is not possible as it next update of=20
> >> linux-firmware package will overwrite it back. It break any normal usa=
ge=20
> >> of package management.
> >>=20
> >> Also it is ridiculously broken by design if some "boot" files needs to=
=20
> >> be overwritten to initialize hardware properly. To not break booting y=
ou=20
> >> need to overwrite that file before first boot. But without booting=20
> >> device you cannot read calibration data. So some hack with autoreboot=
=20
> >> after boot is needed.
>=20
> Providing the calibration data via Device Tree is the proper way to
> solve this. Yes yes, I know N900 doesn't support it but that's a
> deficiency in N900, not Linux.

Linux has to work with whatever hardware provides. You may not like
N900 design, but we have to support it, anyway.

								Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--zYM0uCDKw75PZbzx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlh3Q1kACgkQMOfwapXb+vLRBgCfaqMyZ3ITOaCxDvpMuo5FEZcf
YfUAnR7gu4B5Y/2Mxq1as2HuZasjY9ax
=7x1Q
-----END PGP SIGNATURE-----

--zYM0uCDKw75PZbzx--
