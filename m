From: Thierry Reding <thierry.reding@gmail.com>
Subject: Re: [PATCH] net: dsa: Fix build warning for !PM_SLEEP
Date: Thu, 2 Oct 2014 10:35:00 +0200
Message-ID: <20141002083459.GD30167@ulmo>
References: <1412164740-32452-1-git-send-email-thierry.reding@gmail.com>
 <20141001.152452.1973501659924138094.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="sXc4Kmr5FA7axrvy"
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141001.152452.1973501659924138094.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--sXc4Kmr5FA7axrvy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Oct 01, 2014 at 03:24:52PM -0400, David Miller wrote:
> From: Thierry Reding <thierry.reding@gmail.com>
> Date: Wed,  1 Oct 2014 13:59:00 +0200
>=20
> > From: Thierry Reding <treding@nvidia.com>
> >=20
> > The dsa_switch_suspend() and dsa_switch_resume() functions are only used
> > when PM_SLEEP is enabled, so they need #ifdef CONFIG_PM_SLEEP protection
> > to avoid a compiler warning.
> >=20
> > Signed-off-by: Thierry Reding <treding@nvidia.com>
>=20
> Applied.
>=20
> Please, in the future, explicitly indicate what tree your changes
> are against.  Through trial and error I figured out that this could
> only apply to net-next, but that's not a good use of my time.

I had assumed that working on top of linux-next is what most people were
doing anyway therefore net-next would be the default to apply patches to
unless otherwise stated.

But if this inconveniences you I'll try to remember to explicitly state
which tree it's based on in the future.

Thierry

--sXc4Kmr5FA7axrvy
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJULQ4zAAoJEN0jrNd/PrOh25EQAIUNAzqeSp+J/DL7fz4IPRkY
F3VnIZGAqGdXyPeA6FXPuTPtdjXSysfywQauv5fXlsFH+yjY1rQ4XyTjJh5nrIns
tnXgC9rBFg80iZ2sgfBeEwtkhNbHHxu1ule5tS86hjyhxQeNr+eB2sbkXQ3uk1+A
FXmnC7A7wxXUDbpM92Dp54+BatRTFq3ythszufJj5hVACvEK7Qju15EBS8xS/rTg
ge6Q5WttEWxcy7yTrtwYGngVDGXMhEiuQfFwgf9wxdOoFF2fXyB26s10r1aNGavK
85O0ksd/Pux+vXiIn7rAEM5MGkefff4tB/6kgybKpRJsrGXeDf+2pwlCIciQUDE8
NQQUyCnscHwq5cH7u+xa1qb6c0DgD4dp/SjRqvQe5AX94pjofjspO1QVBnY4WU0z
JSMalqJe2cxxW+swxlDxvO6/qdqjQvX0W0l/y/HOB1T1Sx9mzejybDCzxs4nccT7
yTeFXl/cQhZIa2n1FCo0267aWz+97/a/pPhX9OpIxiSHwTWbFYiE7rTU8Ts3+Lll
jW+fRT5g7PcKTlBEpriTg0S45gab6Rltm8XapY0aOH25DRcqEH0D2x/zfteD4XIc
H4PaP+BYA7YJ6zw0XeFBmiR78e5Aoqjv5eoLlNCRKnSr1EbE8g5qTNzUrMQfEa1r
hmitv3C6vv5J0oLRWRa5
=iq5q
-----END PGP SIGNATURE-----

--sXc4Kmr5FA7axrvy--
