From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 4/6] wl1251: Generate random MAC address only if driver
 does not have valid
Date: Sat, 24 Dec 2016 19:08:54 +0100
Message-ID: <20161224180854.GB13590@amd>
References: <1482598381-16513-1-git-send-email-pali.rohar@gmail.com>
 <1482598381-16513-5-git-send-email-pali.rohar@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="61jdw2sOBCFtR2d/"
Cc: Ming Lei <ming.lei@canonical.com>,
        "Luis R. Rodriguez" <mcgrof@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Kalle Valo <kvalo@codeaurora.org>,
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
In-Reply-To: <1482598381-16513-5-git-send-email-pali.rohar@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--61jdw2sOBCFtR2d/
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat 2016-12-24 17:52:59, Pali Roh=E1r wrote:

> Before this patch driver generated random MAC address every time when was
> doing initialization. And after that random MAC address could be
> overwritten with fixed one if provided.

Before this patch, driver generated random MAC address every time it
was initialized. After that random MAC address could be overwritten
with fixed one, if provided.

> This patch changes order. First it tries to read fixed MAC address and if
> it fails then driver generates random MAC address.

I don't quite get where the advantage is supposed to be. Is it that
"use_eeprom" is set, but reading fails?

The only case where this helps is if wl1251_read_eeprom_mac() succeeds
but reads invalid address.

> Signed-off-by: Pali Roh=E1r <pali.rohar@gmail.com>

Acked-by: Pavel Machek <pavel@ucw.cz>

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--61jdw2sOBCFtR2d/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlheubYACgkQMOfwapXb+vIyQwCdHnMZRs1gP+0fFLzljMI/LP9i
ORoAnjZNxIOvX6ZgTsPI0Ezdv31jVoyW
=YUn2
-----END PGP SIGNATURE-----

--61jdw2sOBCFtR2d/--
