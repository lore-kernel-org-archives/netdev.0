From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH net-next] can: fix build error without CONFIG_PROC_FS
Date: Thu, 27 Apr 2017 16:29:46 +0200
Message-ID: <937e9144-c06c-d265-29eb-a1c6f96b6f89@pengutronix.de>
References: <20170427142146.3107957-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="cjiqFJODSB0jwJxw4bPpuA5JnNGst9li1"
Cc: Thomas Gleixner <tglx@linutronix.de>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Mario Kicherer <dev@kicherer.org>,
        Eric Dumazet <edumazet@google.com>, linux-can@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>,
        Oliver Hartkopp <socketcan@hartkopp.net>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20170427142146.3107957-1-arnd@arndb.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--cjiqFJODSB0jwJxw4bPpuA5JnNGst9li1
Content-Type: multipart/mixed; boundary="fJFcolD8RlvilxddcSU38f0QA68Wtpxeb";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Arnd Bergmann <arnd@arndb.de>, Oliver Hartkopp <socketcan@hartkopp.net>,
 "David S. Miller" <davem@davemloft.net>
Cc: Thomas Gleixner <tglx@linutronix.de>, Cong Wang
 <xiyou.wangcong@gmail.com>, Mario Kicherer <dev@kicherer.org>,
 Eric Dumazet <edumazet@google.com>, linux-can@vger.kernel.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Message-ID: <937e9144-c06c-d265-29eb-a1c6f96b6f89@pengutronix.de>
Subject: Re: [PATCH net-next] can: fix build error without CONFIG_PROC_FS
References: <20170427142146.3107957-1-arnd@arndb.de>
In-Reply-To: <20170427142146.3107957-1-arnd@arndb.de>

--fJFcolD8RlvilxddcSU38f0QA68Wtpxeb
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hello Arnd,

On 04/27/2017 04:21 PM, Arnd Bergmann wrote:
> The procfs dir entry was added inside of an #ifdef, causing a build err=
or
> when we try to access it without CONFIG_PROC_FS set:
>=20
> net/can/bcm.c:1541:14: error: 'struct netns_can' has no member named 'b=
cmproc_dir'
> net/can/bcm.c: In function 'bcm_connect':
> net/can/bcm.c:1601:14: error: 'struct netns_can' has no member named 'b=
cmproc_dir'
> net/can/bcm.c: In function 'canbcm_pernet_init':
> net/can/bcm.c:1696:11: error: 'struct netns_can' has no member named 'b=
cmproc_dir'
> net/can/bcm.c: In function 'canbcm_pernet_exit':
> net/can/bcm.c:1707:15: error: 'struct netns_can' has no member named 'b=
cmproc_dir'
>=20
> This adds the same #ifdef around all users of the pointer. Alternativel=
y
> we could move the pointer outside of the #ifdef.
>=20
> Fixes: 384317ef4187 ("can: network namespace support for CAN_BCM protoc=
ol")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

A fix for this problem is part of the pull request I send to David
earlier today:

    https://www.mail-archive.com/netdev@vger.kernel.org/msg165764.html

regards,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--fJFcolD8RlvilxddcSU38f0QA68Wtpxeb--

--cjiqFJODSB0jwJxw4bPpuA5JnNGst9li1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEE4bay/IylYqM/npjQHv7KIOw4HPYFAlkCAFoACgkQHv7KIOw4
HPbH1Qf9H/EHdYLAXPhJ0cPqBRw7k9EaW4VmElKqf7w4MAUA1J3p5aUZzEL2uY8C
337RyNA9eTXybmJtDZRbb5DKPxC+2d6aJSoY9jUJ3vWIF2w1ZrfGJEtg5vYYX4J1
O4CYMlrPyR93ZMReCePlOxOGG6WLijH00B1MCFB2uAslEGqmOup3yTNliA2p+SHY
yKM4rSmnWEVn2G57CQahB54wIg6ZbdG1v64DwLzwg7a6qem2T9XEnpF7Tex+SF0/
5RWYdQIkXkC6Awor+H1BR6FwKX4MOwdExlXQhcHf0hZMycqKp7hgWs59Cz33uDOJ
xCafKWHEAu5fjMEub8Yo4Z0TIFLApw==
=MP4x
-----END PGP SIGNATURE-----

--cjiqFJODSB0jwJxw4bPpuA5JnNGst9li1--
