From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: powerpc allmodconfig
Date: Sat, 18 Oct 2008 14:20:02 +0200
Message-ID: <1224332402.6324.0.camel@johannes.berg>
References: <20081015213337.a99a9595.akpm@linux-foundation.org>
	 <20081015.220247.262683261.davem@davemloft.net>
	 <1224169039.735.57.camel@johannes.berg>
	 <20081016.124923.222595655.davem@davemloft.net>
	 <20081016130237.4984967c@infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-qXvhJ3JmCNBpXIwnMVne"
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	dan.j.williams@intel.com, tiwai@suse.de,
	linux-ext4@vger.kernel.org, netdev@vger.kernel.org,
	linux-ide@vger.kernel.org, bzolnier@gmail.com,
	marek.vasut@gmail.com, dwmw2@infradead.org, mark.fasheh@oracle.com,
	ralf@linux-mips.org, mchehab@infradead.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <linux-ext4-owner@vger.kernel.org>
In-Reply-To: <20081016130237.4984967c@infradead.org>
Sender: linux-ext4-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-qXvhJ3JmCNBpXIwnMVne
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2008-10-16 at 13:02 -0700, Arjan van de Ven wrote:
> On Thu, 16 Oct 2008 12:49:23 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> > #endif
> > #define __WARN() warn_on_slowpath(__FILE__, __LINE__)
> > #define __WARN_printf(arg...) warn_slowpath(__FILE__, __LINE__, arg)
> > #else
> > #define __WARN_printf(arg...) __WARN()
>=20
> the easiest way I suppose would be to do
>=20
> #define __WARN_printf(arg..) do { printk(arg); __WARN(); } while (0)
>=20
> any obvious problems with this ?

No, not really. You won't get it on kerneloops, but I guess that's not
an easily tractable problem.

johannes

--=-qXvhJ3JmCNBpXIwnMVne
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJI+dRuAAoJEKVg1VMiehFYmDYP/0kTJWdpsf24PrUnYtMIXVLv
C46H78KmP/qVYLbDiE0uK4fCq6T5agsZga7fSK5kBA8NiNIL1wXc4X7KjibaDWkr
lEmpAchTZZZgcgO4oW7AAuxoPtFJwJ0GVe8IOU93N+ItbPuCahA+XgbSC670VOIT
G5655z9ApbE1Zk2ovPVezBgOhsQgCNEX+V57ALRLqNrW5/w3yFsaAcJSjWdNQQ6z
YqKBNB96Ds8Y9aJNoFSoG9Y09FU3tuCvN0RyQTURxpwHKZ6f/PWBzdlGUZRYMUh0
dHSrUvow0SzAFhWyZmhmAeRtCwC2F0T95wxun9LOht4o37hrKE3xN9ScIbSOFIYq
m8KD5ZAd39nFuCEj41GBi4B0CRy0IhTqGeCIRqyVFYtKSFR4M+eJ9fskrPyWYJXI
zofkGWlIqKBIGM9v8vMBWX5dalocIFBZFyYiPj/NYMsMRsRfJ33i0UVYk6VGijIs
8b5gyl5ASmS/yjJAB5DwOQEW7UZs2RrTFSKI0A9BlQOp73Qplwdie7zas7QK/wHM
vtosJ2/aTo3SdLumy+B9KphBwJBk09FxhNiU76aJnLtXsWnQ0/9kxQKlfW9dctTi
bKCqB8k2XhGkZ13SEJvpKs9WGSfLXchv2kAOs/O7P+OWEMaz/4FpbZPhV+CGn5Ty
Ff7sKOr58jw93iMShX+S
=OjGy
-----END PGP SIGNATURE-----

--=-qXvhJ3JmCNBpXIwnMVne--

