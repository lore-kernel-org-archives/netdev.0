From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: powerpc allmodconfig
Date: Thu, 16 Oct 2008 16:57:19 +0200
Message-ID: <1224169039.735.57.camel@johannes.berg>
References: <20081015213337.a99a9595.akpm@linux-foundation.org>
	 <20081015.220247.262683261.davem@davemloft.net>
	 (sfid-20081016_070321_484206_CF986FB8)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-RwDHazsTlsfHEjp3GDNS"
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, tiwai-l3A5Bk7waGM@public.gmane.org,
	linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-ide-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	marek.vasut-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, mark.fasheh-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org,
	ralf-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, mchehab-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, Arjan van de Ven <arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20081015.220247.262683261.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> (sfid-20081016_070321_484206_CF986FB8)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-RwDHazsTlsfHEjp3GDNS
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2008-10-15 at 22:02 -0700, David Miller wrote:
>=20
>=20
> > net/sched/sch_generic.c: In function 'dev_watchdog':
> > net/sched/sch_generic.c:224: warning: unused variable 'drivername'
>=20
> Sucky, if WARN_ONCE() evaluates to nothing the sprintf() string buffer
> on the stack looks unused.

I've complained about this to Arjan before, we actually lose all
messages passed to WARN() or WARN_ONCE() on platforms that use bug traps
for warnings too.

johannes

--=-RwDHazsTlsfHEjp3GDNS
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJI91ZLAAoJEKVg1VMiehFYYlcQAIVtjS9xcVR3ZmM6893/7UIV
2XEXfwlKMLunk5fBVAPz2DF2x83tlyNHrALOW1zTWjM2teLzKCq0XtFsXIoMrUX5
0AuQBKmN/nf2+93YbfBH73zWmeegBz0yO1IaCdnjDT5P0Orn6mj4h7OBnb1u2Dxo
pNK/wOiX/v/2MKrfQnEBo9LHqMmlGonbvFPxBIVOeONzsjlv5BVMWqPhfxf9D7wI
m1GIDO13dYZ/ZkKuC5SchD+UJhFhPZd2pG1rxK8eRctDJXHa1dFEcVLrQq9zshBL
7xJ5n4jdw1M5PVKNB4Frd3H1nv8PGNKoNliodaNwj/ZC5ULxZXnFxECkPl3VGU63
5cUVGYTsqHUewPT7TigoYTD45AU85LWyhYHtN63hqbkeNH5Sf2QgN5XwQ7Wb3Urm
gk3MMi01RcUvuV0MtiWsqZ/Cu1HM6S4QsgxypZ7gtv867LiB17c3ucVbswPVRGgZ
A036WQSNA+gAQU3tV5J5D9eq8lphlmioLfUq4/mPKSn+UgI22iYMTPk9hMY/3dkZ
Iox3vd7GfiDiPmNoHaF27w9dlQURjU3ue0eC5G5gUvImzawU3l6bmVEHoNhT/DUJ
Q+2NSFvtZhYzFm1TUnHpyF0KYnAz6pogNY8155qCZ5dX7Wlc2wgpUkZJpdhc8iv9
nb5xAVWpNharfmm23n+R
=pg7B
-----END PGP SIGNATURE-----

--=-RwDHazsTlsfHEjp3GDNS--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
