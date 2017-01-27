From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 2/6] wl1251: Use request_firmware_prefer_user() for
 loading NVS calibration data
Date: Fri, 27 Jan 2017 13:03:22 +0100
Message-ID: <20170127120321.GB8512@amd>
References: <1482598381-16513-1-git-send-email-pali.rohar@gmail.com>
 <1482598381-16513-3-git-send-email-pali.rohar@gmail.com>
 <87tw8lnei3.fsf@codeaurora.org>
 <20170127094342.GC24223@pali>
 <def4c357-64c0-0681-a5d5-f49a6cb84a92@broadcom.com>
 <20170127101043.GD24223@pali>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="qcHopEYAB45HaUaB"
Cc: Arend Van Spriel <arend.vanspriel@broadcom.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Ming Lei <ming.lei@canonical.com>,
        "Luis R. Rodriguez" <mcgrof@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        David Gnedt <david.gnedt@davizone.at>,
        Michal Kazior <michal.kazior@tieto.com>,
        Daniel Wagner <wagi@monom.org>,
        Tony Lindgren <tony@atomide.com>,
        Sebastian Reichel <sre@kernel.org>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Grazvydas Ignotas <notasas@gmail.com>,
        linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org
To: Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170127101043.GD24223@pali>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--qcHopEYAB45HaUaB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> > You are probably saying that on your platform you can not remove
> > anything from /lib/firmware, right? I don't see how you come from "it is
> > part of firmware package" to "removing is not possible". Trying to
> > understand this and it makes no sense.
>=20
> It is already in linux distribution packages. If I remove that file from
> file system it will be placed there again by package management or it it
> will throw error message about system integrity (missing file, etc...).
>=20
> Also that file is already in linux-firmware git and so is propagated to
> /lib/firmware by anybody who is using linux-firmware.
>=20
> > >> Like we discussed earlier, the default nvs file should not be used by
> > >> normal users.
> > >=20
> > > But already is and we need to deal with this fact.
> >=20
> > Why?
>=20
> Because everybody has already installed it.
>=20
> > Are there other platforms that use the default nvs file and have a
> > working wifi.
>=20
> I do not know.
>=20
> > So your "removing is not possible" would be about
> > regression for those?
>=20
> Yes, that is possible.
>=20
> Also you can use wifi on Nokia N900 with this default file. Yes it is
> not recommended and probably has performance problems... but more people
> use it for SSH and it is working. Pavel could confirm this.

Yes, wifi somehow works on N900. .. depending on userspace and kernel
versions.

									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--qcHopEYAB45HaUaB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAliLNwkACgkQMOfwapXb+vKH8gCgkdSnJsJtKo2pPK6bph+wEtf4
YxMAmgKrAQFt6KQ9BwDPB23NkWOGZpcV
=Wc/q
-----END PGP SIGNATURE-----

--qcHopEYAB45HaUaB--
