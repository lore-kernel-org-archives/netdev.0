From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [v3,1/2] b43: Remove unused phy_a code
Date: Thu, 16 Jun 2016 17:48:13 +0200
Message-ID: <20160616174813.595440bb@wiggum>
References: <1465052053-26740-1-git-send-email-linux@roeck-us.net>
 <20160616152337.63AB261421@smtp.codeaurora.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/=g+V3lU6j99hQWOpsQXj8tN"; protocol="application/pgp-signature"
Cc: Guenter Roeck <linux@roeck-us.net>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	b43-dev@lists.infradead.org
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160616152337.63AB261421@smtp.codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/=g+V3lU6j99hQWOpsQXj8tN
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Thu, 16 Jun 2016 15:23:37 +0000 (UTC)
Kalle Valo <kvalo@codeaurora.org> wrote:

> Guenter Roeck <linux@roeck-us.net> wrote:
> > gcc-6 reports the following error with -Werror=3Dunused-const-variable.
> >=20
> > drivers/net/wireless/broadcom/b43/phy_a.c:576:40: error:
> > 	'b43_phyops_a' defined but not used
> >=20
> > Per Michael B=C3=BCsch: "All a-phy code is usused", so remove it all,
> > and move the remaining Type-G initialization code into phy_g.c.
> >=20
> > Reported-by: Fengguang Wu <fengguang.wu@intel.com> [0-day test robot]
> > Cc: Michael B=C3=BCsch <m@bues.ch>
> > Signed-off-by: Guenter Roeck <linux@roeck-us.net> =20
>=20
> Thanks, 2 patches applied to wireless-drivers-next.git:
>=20
> 9791333a840f b43: Remove unused phy_a code
> afdfdc481ea9 b43: Completely remove support for phy_a


Did anybody test this on any hardware?
I think this should be tested on some G-PHY hardware, before it goes to
Linus.


--=20
Michael

--Sig_/=g+V3lU6j99hQWOpsQXj8tN
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXYso9AAoJEPUyvh2QjYsOtqgQAMlfVrT5uT0u5iaWqi0+QWPG
+R8phtun+QrIqmgxQjsmsm1s39rTWxtCEUm1SMuEAlEs4ygL0qYNBwnNrHzLycq/
3auybqr9z17tNrvMGkHCllkgzdjrPJXcncoptW6SlYYe2tb2suzpOrIni2QWKycr
bzGDeT6LTs/GeNgPaymQ7On4utYbGivSKhMM6pC15xQ7h1m8kyaWwjg6Ri8CvXwC
iJHrbwb03aqxQOPtwAsBV4IyNi1MmhQX3IdfnDTdLjc/zfMFSbsYysjUNgndFys8
iWwVJwQTezg32opnmvf/I3EhNSztg7NLQWfUTEnFOZQ3NdP3wWtVwi1MMWo/wosP
ykTRSxy9Wca2Up2feD1GuZrQK5tFjEvLb/JqrJ37htd32tPEbLxHYnuxJEMaUN3T
UGLNSYZzaVft74Tvaf1XascgITtpa1Ky7zp+pp/w+tcgUQkrY+s5in6xGC5hSHbs
MU6WsL4M04R37re/wcqdQlLkgIChDloB5dcleuFVyj5xMY8O8YRZd/chov2tmORr
3x+VBASowttRih2I9BLk0I+MoNBM1pHZaM1+cIdPFmNZ1VOqSQsI8y9juvzfCj61
O8ysdgFIwHp6eW6+3Oel5QuPLQKYTnAfkAUWtD7V6Gww/RVJrVUmVLahfQnA8t2d
dAT9XGnp3ppRCbZZKScq
=nb6B
-----END PGP SIGNATURE-----

--Sig_/=g+V3lU6j99hQWOpsQXj8tN--
