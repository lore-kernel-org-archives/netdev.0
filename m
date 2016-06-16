From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [v3,1/2] b43: Remove unused phy_a code
Date: Thu, 16 Jun 2016 18:05:58 +0200
Message-ID: <20160616180558.1d682d9e@wiggum>
References: <1465052053-26740-1-git-send-email-linux@roeck-us.net>
	<20160616152337.63AB261421@smtp.codeaurora.org>
	<20160616174813.595440bb@wiggum>
	<87y465unz5.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/lu_T2eW5nuWK50zDeG3Eeer"; protocol="application/pgp-signature"
Cc: Guenter Roeck <linux@roeck-us.net>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	b43-dev@lists.infradead.org
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87y465unz5.fsf@kamboji.qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/lu_T2eW5nuWK50zDeG3Eeer
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Thu, 16 Jun 2016 18:56:14 +0300
Kalle Valo <kvalo@codeaurora.org> wrote:

> Michael B=C3=BCsch <m@bues.ch> writes:
>=20
> > On Thu, 16 Jun 2016 15:23:37 +0000 (UTC)
> > Kalle Valo <kvalo@codeaurora.org> wrote:
> > =20
> >> Guenter Roeck <linux@roeck-us.net> wrote: =20
> >> > gcc-6 reports the following error with -Werror=3Dunused-const-variab=
le.
> >> >=20
> >> > drivers/net/wireless/broadcom/b43/phy_a.c:576:40: error:
> >> > 	'b43_phyops_a' defined but not used
> >> >=20
> >> > Per Michael B=C3=BCsch: "All a-phy code is usused", so remove it all,
> >> > and move the remaining Type-G initialization code into phy_g.c.
> >> >=20
> >> > Reported-by: Fengguang Wu <fengguang.wu@intel.com> [0-day test robot]
> >> > Cc: Michael B=C3=BCsch <m@bues.ch>
> >> > Signed-off-by: Guenter Roeck <linux@roeck-us.net>   =20
> >>=20
> >> Thanks, 2 patches applied to wireless-drivers-next.git:
> >>=20
> >> 9791333a840f b43: Remove unused phy_a code
> >> afdfdc481ea9 b43: Completely remove support for phy_a =20
> >
> > Did anybody test this on any hardware? I think this should be tested
> > on some G-PHY hardware, before it goes to Linus. =20
>=20
> Larry tested these:
>=20
> "These two patches have been tested on a BCM4318."
>=20
> https://patchwork.kernel.org/patch/9154719/


Ah OK. I forgot.
Everything is fine then.

--=20
Michael

--Sig_/lu_T2eW5nuWK50zDeG3Eeer
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXYs5mAAoJEPUyvh2QjYsOoR8P/AteuEOom+iy/iatxHEJx/im
Yx1Bq4pomneAAfvoeok1zJNevrQgGkAW6NzLiM2iYL7qtjvhYbokwbU67tgprZh6
huWGfTEC0g0XP05IXyoN1xUv7wLXHUMuzreOkxOI1Zo/FIFRBC/dg8rj25qCc4Nq
K8ktu5bmiToUoR02fGy9ZbWUQAtTbZJ9EJXegKNtGfBaucdrHxUNEAIUeJexVwk1
Kgf1pHgbT+zfr2gOaNotAlMx4mhPLVFldm/WubcEtfDbz2c/Ex658JQ/RLO7aliC
+LZit9/iAxN+qFXBh5vt5OxkKjgGjErgu0l9MEdVOqGoOi2yL1f32geqvMidBRyO
nIeOy/6MTq2mNmNntdoKbFIo9QM7ocoQ328rQcuK86Y33TnYvrA07cqWaQ+HwvIL
6PmY6+5Ga3y90Ga2L3SiTLXf3pNi0EEcM5HM+mIWT8HX32R9WZFA5Ku6KcY8NB8y
HphDVk2JHtOreCKa+pfeZtuFY97ApclXzF79FYVIb2qboeFgfodAnPwH2NCOKS0N
QpiEA8ZTbEvDStvmE2ZtwFLpLGGGHhoCL+uf6/x+PFUNqCTH/3T2HwtohChSZhKI
X91hzQ8wCiVLyPSdNrjK3RH/Q96kMa1u6fG9cCrkQZs8v9hr7dZ6AuKoSfzeSmZv
cm9IPF+xs1DfEQHdsw0/
=JWKQ
-----END PGP SIGNATURE-----

--Sig_/lu_T2eW5nuWK50zDeG3Eeer--
