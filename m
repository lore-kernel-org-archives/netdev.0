From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: fix warning in bcm_connect/proc_register
Date: Thu, 27 Oct 2016 10:47:28 +0200
Message-ID: <c25b97be-7330-a648-c207-16c93282d07f@pengutronix.de>
References: <20161024191126.30256-1-socketcan@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="bLDjNK7ir05wU9qpehexLsLGCmXKawrJD"
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, syzkaller@googlegroups.com,
        kcc@google.com, glider@google.com, dvyukov@google.com,
        edumazet@google.com
To: Oliver Hartkopp <socketcan@hartkopp.net>, andreyknvl@google.com,
        xiyou.wangcong@gmail.com, davem@davemloft.net
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20161024191126.30256-1-socketcan@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--bLDjNK7ir05wU9qpehexLsLGCmXKawrJD
Content-Type: multipart/mixed; boundary="LmcKubxrAGma1IFtoieuRe4ootxwnSQch";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Oliver Hartkopp <socketcan@hartkopp.net>, andreyknvl@google.com,
 xiyou.wangcong@gmail.com, davem@davemloft.net
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, syzkaller@googlegroups.com, kcc@google.com,
 glider@google.com, dvyukov@google.com, edumazet@google.com
Message-ID: <c25b97be-7330-a648-c207-16c93282d07f@pengutronix.de>
Subject: Re: [PATCH] can: fix warning in bcm_connect/proc_register
References: <20161024191126.30256-1-socketcan@hartkopp.net>
In-Reply-To: <20161024191126.30256-1-socketcan@hartkopp.net>

--LmcKubxrAGma1IFtoieuRe4ootxwnSQch
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 10/24/2016 09:11 PM, Oliver Hartkopp wrote:
> Andrey Konovalov reported an issue with proc_register in bcm.c.
> As suggested by Cong Wang this patch adds a lock_sock() protection and
> a check for unsuccessful proc_create_data() in bcm_connect().
>=20
> Reference: http://marc.info/?l=3Dlinux-netdev&m=3D147732648731237
>=20
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Suggested-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

Added with Andrey Konovalov Tested-by to can/master with stable on Cc.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--LmcKubxrAGma1IFtoieuRe4ootxwnSQch--

--bLDjNK7ir05wU9qpehexLsLGCmXKawrJD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJYEb8iAAoJED07qiWsqSVqxoUIAJR2ugHxlcaFWz4C4ziKTKTt
7GELb3Snz5FT9oBrz4eVNtD8L5N3woxU3KqgdU1F4SIaMyDwC/lVbbq4eGMbgyzd
dG8idaBSSKsQnCntPlDG9+icwg3/Xhyn0l02C+ToBbNSnq4DbxwCOAmIHuet/nMj
Ze/oglOpJmkLy7qbhkpwxB6tQP8/wmT+/xFJnSp+mV9QgzL3bnhIcdYTVVM7Rp+o
PBZuCdmNH9t+sJEd18s388OHSpj9Px/+b2g8eVxzPF7aF7EaUgGJUSRGYNfEK3oF
JBv4Q84px1D4OBWdqNKH8WG/bh7STCTdTjvEgBSjevVDNEZMOW3SZh/hPdF/y2U=
=eLRx
-----END PGP SIGNATURE-----

--bLDjNK7ir05wU9qpehexLsLGCmXKawrJD--
