From: Daniel Micay <danielmicay@gmail.com>
Subject: Re: [kernel-hardening] Re: [PATCH v2 1/4] siphash: add
 cryptographically secure hashtable function
Date: Thu, 15 Dec 2016 03:15:55 -0500
Message-ID: <1481789755.1114.7.camel@gmail.com>
References: <20161215075746.GA14699@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
        protocol="application/pgp-signature"; boundary="=-pvzr9/pWTtzmrv3MGuJ6"
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-crypto@vger.kernel.org,
        jeanphilippe.aumasson@gmail.com, djb@cr.yp.to,
        torvalds@linux-foundation.org, ebiggers3@gmail.com
To: kernel-hardening@lists.openwall.com,
        "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161215075746.GA14699@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-pvzr9/pWTtzmrv3MGuJ6
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2016-12-15 at 15:57 +0800, Herbert Xu wrote:
> Jason A. Donenfeld <Jason@zx2c4.com> wrote:
> >=20
> > Siphash needs a random secret key, yes. The point is that the hash
> > function remains secure so long as the secret key is kept secret.
> > Other functions can't make the same guarantee, and so nervous
> > periodic
> > key rotation is necessary, but in most cases nothing is done, and so
> > things just leak over time.
>=20
> Actually those users that use rhashtable now have a much more
> sophisticated defence against these attacks, dyanmic rehashing
> when bucket length exceeds a preset limit.
>=20
> Cheers,

Key independent collisions won't be mitigated by picking a new secret.

A simple solution with clear security properties is ideal.
--=-pvzr9/pWTtzmrv3MGuJ6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQJKBAABCAA0FiEEZe7+AiEI4rcIy/z3+ecS5Zr18ioFAlhSUTsWHGRhbmllbG1p
Y2F5QGdtYWlsLmNvbQAKCRD55xLlmvXyKtU7D/9JrDSIgP36QyS7NWpyMKNcgyEj
v/g3q8vizZL3qUtHmIWjElPWL2EyrFH/56fhsyc2oNWbJCB1eyB57ZE9tBhYpwD7
BWfrmVLb1EOeimnWLpEMe5Pc3TB5QtfRPbkKfhQF5YaH1B1kAhO85f32Mdswl1hY
UdAyl2n/IBZIk8/XStHDT6v2cK3/+QSykX3bE8QNs0zSAT1vFuJPV0LL7FYUa3DQ
N9mfC/5OW1Ybj6+ge6gdGjT7uIjKfTAYCVCn6Fbnu7JR2jVF7jA4Dqf/CkhNyGiy
plStmlJplLErlQsTsDwd6mhlPkGFsxRlgaKwByAHuzR7zOONIcTidaFmCTPUwYFP
t0oTVapnR96nBI09dAzuAvCplIoh47KzP6xy+UU9l5w6h/OT+j3SeFbrSFnR0qhT
PAO03WZesVaO2T9ZJOgq7mzFKa+9S+glaxGdoNvuk+rPFRYOoP+DZF3j6uChP5Zt
nCwhfhmr+NK1v7SL+ZN7+Qkf3HYQK9C8tfFVAYe8Vi1quI0J61dc5Y8aidlq/gd7
bzzt71I3Gn6PJhSnPuTXA5i/h2KNLm8So/FNVxnf4T7WJo0dcMBhdNPDXpEFDInJ
NCdHvSa+1mYFP+fK29uuPzobUoYz+0ls9Ky8oajMs2MuM0/kdNJf40KPbpIFNbeO
237zuy9aajmiVPPJqQ==
=T1IV
-----END PGP SIGNATURE-----

--=-pvzr9/pWTtzmrv3MGuJ6--
