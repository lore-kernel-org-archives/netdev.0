From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: net/can: trying to register non-static key in can_rx_register
Date: Thu, 8 Jun 2017 17:20:54 +0200
Message-ID: <97710f24-092e-ade4-fa14-3bc812bbf42f@pengutronix.de>
References: <CAAeHK+ywJzK4Hd=O_+j+Dw7pb=s-MgwVLJywrLAQdkwfybdu1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="vPDxnfSKlxAw2OITTXCMtCMfFFB2MCgTr"
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>,
        Oliver Hartkopp <socketcan@hartkopp.net>,
        "David S. Miller" <davem@davemloft.net>, linux-can@vger.kernel.org,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+ywJzK4Hd=O_+j+Dw7pb=s-MgwVLJywrLAQdkwfybdu1Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--vPDxnfSKlxAw2OITTXCMtCMfFFB2MCgTr
Content-Type: multipart/mixed; boundary="1OxLwcP52FetWBkQb9mO4DxClmpOFWt5w";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Andrey Konovalov <andreyknvl@google.com>,
 Oliver Hartkopp <socketcan@hartkopp.net>,
 "David S. Miller" <davem@davemloft.net>, linux-can@vger.kernel.org,
 netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>,
 syzkaller <syzkaller@googlegroups.com>
Message-ID: <97710f24-092e-ade4-fa14-3bc812bbf42f@pengutronix.de>
Subject: Re: net/can: trying to register non-static key in can_rx_register
References: <CAAeHK+ywJzK4Hd=O_+j+Dw7pb=s-MgwVLJywrLAQdkwfybdu1Q@mail.gmail.com>
In-Reply-To: <CAAeHK+ywJzK4Hd=O_+j+Dw7pb=s-MgwVLJywrLAQdkwfybdu1Q@mail.gmail.com>

--1OxLwcP52FetWBkQb9mO4DxClmpOFWt5w
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 06/08/2017 05:16 PM, Andrey Konovalov wrote:
> Hi,
>=20
> I've got the following error report while fuzzing the kernel with syzka=
ller.
>=20
> On commit b29794ec95c6856b316c2295904208bf11ffddd9 (4.12-rc4+).
>=20
> INFO: trying to register non-static key.
> the code is fine but needs lockdep annotation.
> turning off the locking correctness validator.

I've posted a patch for this problem earlier today:
https://marc.info/?l=3Dlinux-can&m=3D149691617012069&w=3D2

I'll send a pull request to David soon.

regards,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--1OxLwcP52FetWBkQb9mO4DxClmpOFWt5w--

--vPDxnfSKlxAw2OITTXCMtCMfFFB2MCgTr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEE4bay/IylYqM/npjQHv7KIOw4HPYFAlk5a1YACgkQHv7KIOw4
HPbELgf7B1cTobJNMQGS4GP4bC/kYtN3m5r7LZUXo4hU6aRuZf6eAXcqSQPFUCL5
5HZeV1OQQFyOyzM+tuT+bdvmCI2KM90UxQY1AYVtiPP6rP9OyRxfRX1QaM/NYVqX
YfpLMm51efmfTT6L61GcEcIG2YZy6ceq2jUHFygQcpn0zWrVLiieDcNFtjmdhwMs
2m4o9ccRiegnWyIwaLMH+k0g/JpFjpao0ylAgNaixFB/qVBA8s4mw4L+XqJFlwa5
ZT31IQZkLRhWF3R6sB+UVgM+2FquNctjhIkM+69bgQg1KPeD2ixvUmpYt98FdgeY
X6hu3VxsfO5G8NG5nNM83B+SHa2aRg==
=nhh6
-----END PGP SIGNATURE-----

--vPDxnfSKlxAw2OITTXCMtCMfFFB2MCgTr--
