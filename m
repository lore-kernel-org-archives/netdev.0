From: Daniel Micay <danielmicay@gmail.com>
Subject: Re: Re: [PATCH v5 1/4] siphash: add
 cryptographically secure PRF
Date: Fri, 16 Dec 2016 15:44:27 -0500
Message-ID: <1481921067.1054.6.camel@gmail.com>
References: <CAGiyFdfmiCMyHvAg=5sGh8KjBBrF0Wb4Qf=JLzJqUAx4yFSS3Q@mail.gmail.com>
	 <20161216034618.28276.qmail@ns.sciencehorizons.net>
	 <CAGiyFdd6_LVzUUfFcaqMyub1c2WPvWUzAQDCH+Aza-_t6mvmXg@mail.gmail.com>
	 <CAHmME9pjoAsoct1sVDpFFuqaqutv9X7DGJ5OBQXRAS57KFimUA@mail.gmail.com>
	 <CALx6S351VFRZmEQphRQy6YtmZYPnOtTN7=XiNrJmhWJGv4HUBg@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-HimIJJAsxKuzIQvBsNJ2"
Cc: Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>, George Spelvin
 <linux@sciencehorizons.net>, Andi Kleen <ak@linux.intel.com>, David Miller
 <davem@davemloft.net>, David Laight <David.Laight@aculab.com>, Eric Biggers
 <ebiggers3@gmail.com>, Hannes Frederic Sowa <hannes@stressinduktion.org>,
 Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, LKML
 <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@amacapital.net>,
 Netdev <netdev@vger.kernel.org>, Linus Torvalds
 <torvalds@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>,
 vegard.nossum@gmail.com, "Daniel J . Bernstein" <djb@cr.yp.to>
To: kernel-hardening@lists.openwall.com, "Jason A. Donenfeld"
 <Jason@zx2c4.com>
Return-path: <kernel-hardening-return-5656-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CALx6S351VFRZmEQphRQy6YtmZYPnOtTN7=XiNrJmhWJGv4HUBg@mail.gmail.com>
List-Id: netdev.vger.kernel.org


--=-HimIJJAsxKuzIQvBsNJ2
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-12-16 at 11:47 -0800, Tom Herbert wrote:
>=20
> That's about 3x of jhash speed (7 nsecs). So that might closer
> to a more palatable replacement for jhash. Do we lose any security
> advantages with halfsiphash?

Have you tested a lower round SipHash? Probably best to stick with the
usual construction for non-DoS mitigation, but why not try SipHash 1-3,
1-2, etc. for DoS mitigation?

Rust and Swift both went with SipHash 1-3 for hash tables.
--=-HimIJJAsxKuzIQvBsNJ2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQJKBAABCAA0FiEEZe7+AiEI4rcIy/z3+ecS5Zr18ioFAlhUUisWHGRhbmllbG1p
Y2F5QGdtYWlsLmNvbQAKCRD55xLlmvXyKk2/D/9gAHNr8TZPGEYv7L/vhsOnsssj
HRnq0a6FoJT8FdfNxLwffeh2vPLuOVyMNxhOfZtlXLAVwtk8bZrBpJEkM0FSfeEQ
glKghXGxpnPAtwA2lKX0D9Q8adzUXFUBgxeH1IQuCGcacigsbZf11lnvZU6G++Wj
GRcKdGFnwia6gF0rRfCtpgj7mGf/E/tzPBe/SY44s45tRsVC5bne4VH4vjQeBby7
K6YT3VvfIsMIZzaqAzJyS3op1Lz6wlyPIYL6ABqRPFSDgwAewspMhysL954409Za
stB5EDxG0lU378jBPN2cA54Ys0VM+bFL+gWaM4AZiZngfzQYDPTtzGZXvD8seu9P
0QZ4NxyosoWB5St9dUQzUyYbCmLOBT8gTkKs9EtBOmHcLDHOU6WcgbeVDwqm2T3u
So8o4hRu3cggaWbdVyL9QjXazw2VD8BW0CEH4D+qFBFTmAbIvuo0h48LEQ6inv5G
oTmbusFXUbxHDK8UpRCyWg2WMzKPU8cwNrLcVkQhtijQnuI6nYl8GN3u4EeB0pGM
8BGoOHXm6NA7VydDpu95fhoy6GsQeWmeDknM0Khbwubc75iFz8KU1hxMfkESlvb6
Wwz5flHC6TQXG/S6812MHtVh2+undC8SO19y0mfenLZCieLjqC0kj94h67y4xqEw
+16uBeb7ylA/k7Lgjg==
=l09G
-----END PGP SIGNATURE-----

--=-HimIJJAsxKuzIQvBsNJ2--
