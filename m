From: Mark Brown <broonie@kernel.org>
Subject: Re: [PATCH 1/2] regmap: only call custom reg_update_bits() if reg is
 marked volatile
Date: Mon, 5 Oct 2015 15:57:22 +0100
Message-ID: <20151005145722.GT12635@sirena.org.uk>
References: <1444051772-20270-1-git-send-email-jon@ringle.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="DnHvQagWhP6kG70s"
Cc: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Jon Ringle <jringle@gridpoint.com>
To: jon@ringle.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1444051772-20270-1-git-send-email-jon@ringle.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--DnHvQagWhP6kG70s
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Oct 05, 2015 at 09:29:31AM -0400, jon@ringle.org wrote:
> From: Jon Ringle <jringle@gridpoint.com>
>=20
> The only time that it makes sense to call a custom provided reg_update_bi=
ts
> function, is the register being updated is one that has volatile bits.
> Otherwise, the normal read/modify/write cycle (where the read is likely to
> be free from the cache) will do just fine. This should keep the reg cache
> intact, since volatile registers won't get cached anyway.

Dave, to be clear please do *not* apply this patch at least for the time
being - I've not reviewed it or the one from Thursday that you applied
this morning.

--DnHvQagWhP6kG70s
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJWEo/MAAoJECTWi3JdVIfQiBcH/1LyHRkVmLO9m9OxnbYg5feW
LTWqlSekmJELp6HoWtb6tQdw9ZCqcqbQAHXbyPT5/bj/eK8d7ikkHX8t9sK8u/nr
5vWw8IkEm/7qhh/AxmYy+1wRWDB0RoxLtZA8xypVI5ZKnAV56plBylBFZDG5nExc
uPuu7ZmDWjC7mJN6uSYiDKM0IX+E8NCudkEwT924Kslf1AJgfJ+hIAflEiMVCyMy
U3TqljoOaHkehqBVb7Z5kD//uwK1YLmqpu0AbFdIK7b0kjKdUNY92Lqo+fdMFuvI
EDPsf0aiu4q7RUY79GNlRYVbk+IZtC7EN+WeZOWts4uk93nrM7o1GMk+beYbTYg=
=plO5
-----END PGP SIGNATURE-----

--DnHvQagWhP6kG70s--
