From: Pavel Machek <pavel@ucw.cz>
Subject: Re: stmmac ethernet in kernel 4.9-rc6: coalescing related pauses.
Date: Mon, 5 Dec 2016 23:40:57 +0100
Message-ID: <20161205224057.GB19135@amd>
References: <20161124085506.GA25007@amd>
 <20161124.110416.198867271899443489.davem@davemloft.net>
 <20161124212540.GA24796@amd>
 <b6ac7a3c-6774-9568-1cc0-97074eaa928f@st.com>
 <20161202084511.GA32294@amd>
 <3192a4b6-1e97-048f-a0dd-bfc0f3d96ed8@st.com>
 <20161205101516.GA24936@amd>
 <trinity-efd00e93-2b37-4543-a199-e2cbed9fe455-1480937999976@3capp-gmx-bs18>
 <20161205220221.GA19135@amd>
 <9a85da24-85cf-f94e-908f-a10eecac2369@gmx.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="DBIVS5p969aUjpLe"
Cc: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        alexandre.torgue@st.com, David Miller <davem@davemloft.net>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:35631 "EHLO
        atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752099AbcLEWlA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 17:41:00 -0500
Content-Disposition: inline
In-Reply-To: <9a85da24-85cf-f94e-908f-a10eecac2369@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--DBIVS5p969aUjpLe
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon 2016-12-05 23:37:09, Lino Sanfilippo wrote:
> Hi Pavel,
>=20
> On 05.12.2016 23:02, Pavel Machek wrote:
> >=20
> > we need spin_lock_bh at minimum, as we are locking user context
> > against timer.
> >=20
> > Best regards,
> > 									Pavel
> >=20
>=20
> I was referring to stmmac_tx_clean() which AFAICS is only called from sof=
tirq context,
> (one time in the timer handler and one time in napi poll handler) so a sp=
in_lock() should
> be sufficient. I cant see how this is called from userspace. If it were, =
a spin_lock_bh() had
> to be used, of course.

stmmac_tx_clean() shares lock with stmmac_tx() -- and that's process
context as far as I can tell. So... spin_lock_bh() at
minimum... right?

									Pavel

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--DBIVS5p969aUjpLe
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlhF7PkACgkQMOfwapXb+vJ4pwCfTplKUMFac2fmihfwK6+L0BUE
Ot8AoKhkb0sC+m2bmThDhUKlEvpt7vk7
=s0vP
-----END PGP SIGNATURE-----

--DBIVS5p969aUjpLe--
