From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: Re: [PATCH 5/6] wl1251: Parse and use MAC address from supplied NVS data
Date: Sat, 24 Dec 2016 19:40:24 +0100
Message-ID: <201612241940.24299@pali>
References: <1482598381-16513-1-git-send-email-pali.rohar@gmail.com> <1482598381-16513-6-git-send-email-pali.rohar@gmail.com> <20161224181421.GC13590@amd>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2942364.PuALH76XNU";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Ming Lei <ming.lei@canonical.com>,
        "Luis R. Rodriguez" <mcgrof@kernel.org>,
        "Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
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
To: Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161224181421.GC13590@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2942364.PuALH76XNU
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Saturday 24 December 2016 19:14:21 Pavel Machek wrote:
> On Sat 2016-12-24 17:53:00, Pali Roh=C3=A1r wrote:
> > @@ -1581,10 +1598,16 @@ int wl1251_init_ieee80211(struct wl1251
> > *wl)
> >=20
> >  	wl->hw->queues =3D 4;
> >=20
> > +	if (wl->nvs =3D=3D NULL && !wl->use_eeprom) {
> > +		ret =3D wl1251_fetch_nvs(wl);
> > +		if (ret < 0)
> > +			goto out;
> > +	}
>=20
> Is goto out here good idea? IMNSHO it is copy&paste bug, it should
> just proceed with generating random address.

No, goto is correct here. wl1251 cannot be initialized without NVS data.=20
And when fetching (from userspace) fails it is fatal error.

=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart2942364.PuALH76XNU
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAlhewRgACgkQi/DJPQPkQ1LiOwCfUPdfVot77ESWFNVz9tDcpkn+
ONwAn1TfMlF3B8fbwV4EJsbJVDKZUrti
=7UyF
-----END PGP SIGNATURE-----

--nextPart2942364.PuALH76XNU--
