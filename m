From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of most of the trees
Date: Fri, 29 May 2015 10:34:59 +1000
Message-ID: <20150529103459.4e90212d@canb.auug.org.au>
References: <20150528220607.67a68696@canb.auug.org.au>
	<1432826811.7456.10.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/wPctUqjvJCDZIEGQrzDe7ND"; protocol="application/pgp-signature"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1432826811.7456.10.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/wPctUqjvJCDZIEGQrzDe7ND
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Eric,

On Thu, 28 May 2015 08:26:51 -0700 Eric Dumazet <eric.dumazet@gmail.com> wr=
ote:
>
> We were alerted of this problem thanks to kbuild test robot.
>=20
> This fix is not a definitive one I hope.

No, just something to allow me to get my tree to build so I could go to
bed :-)

> Golden rule is that vmalloc() users must include vmalloc.h themselves,
> not by an indirect include.

Yep, that is a special case of Rule 1.

> I sent one fix, and prepared others, but I prefer that each offender is
> fixed.

Yeah, thanks to Dave for that.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/wPctUqjvJCDZIEGQrzDe7ND
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVZ7Q4AAoJEMDTa8Ir7ZwVhosP+wc60HYnJ06VQli0LyUrxZxA
CZZPUZcJin2Vztl+HY1HlSJzBbAO6G44xB2z9CwANWK8uIh3+Wcr6+BIwTksI0sE
OlIFCz3MeQrQfGbty7J/dIBiuH2MStt7IwElWxOB/xqn9Hl8dOduULLzgiGOU2Gm
yA6zmzqvkVouRmb1lV0sB0ub1FpUZfLYFb4LJYeUz1GEv5Q8BLy8MSzda+QEPg2s
ScMEY+IvufKlCw4IBzU9k1sdQIc1IHQK7nLznRRzn/UKa5ym+vuHWUnL4MPspVVK
w44SX/xx20evlfpSM7XSknO7mFD8qIhLhh3SglUji8oYzOkrYFY3Id0nJ7Td+wJS
M60FgM+EYrD8xPA7zyxmmwsWIZgYUSWkJSLOEZHPRsxxkeIgQaLTlny6PlF+bMg2
oFSPJAiFz6IHyoWerbi22OMksgWObmBkMrK8I88k2nOC4l8b2kLpSjvgoBbJ1hD1
9godo6bSogG2M6IIb1ivQP3p/8SCN9oaco+eeILCBNBvyviGGxRkJW0DGh3tEbvS
74r0zlqiIM852YJmDxvjL3VsvC9rR7DhT3N2rM2sVMKtc+eREhaddHhyWrO461Ns
Ed0Fzt1UKFHU3C6qaLgLU0vw5+JboXsyU0L3d1CW4o9tea/t0HaNvehbd2qx0Urg
dzNmvke18Y1Dc+nAwreR
=IAab
-----END PGP SIGNATURE-----

--Sig_/wPctUqjvJCDZIEGQrzDe7ND--
