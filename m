From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: Re: [PATCH] net: batman-adv: use new api
	ethtool_{get|set}_link_ksettings
Date: Fri, 31 Mar 2017 08:50:35 +0200
Message-ID: <5459529.jjAg0OrKDG@bentobox>
References: <1490907687-11784-1-git-send-email-tremyfr@gmail.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart1661950.8mvZZ1hylZ";
 micalg="pgp-sha512"; protocol="application/pgp-signature"
Cc: mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, a@unstable.cc,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
 Philippe Reynes <tremyfr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1490907687-11784-1-git-send-email-tremyfr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

--nextPart1661950.8mvZZ1hylZ
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="iso-8859-1"

On Donnerstag, 30. M=E4rz 2017 23:01:27 CEST Philippe Reynes wrote:
> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
>=20
> I've only compiled this change. If someone may test it,
> it would be very nice.
>=20
> Signed-off-by: Philippe Reynes <tremyfr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  net/batman-adv/soft-interface.c |   25 ++++++++++++-------------
>  1 files changed, 12 insertions(+), 13 deletions(-)

Do you know if anyone already prepared the get_link_ksettings support for
kernels older than 4.6 for backports.git?

Kind regards,
	Sven

--nextPart1661950.8mvZZ1hylZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEF10rh2Elc9zjMuACXYcKB8Eme0YFAljd/DsACgkQXYcKB8Em
e0ZbsA/6A9Ib0kW0i0Vr6zdhPzSLSiSi2z6w9fq3arNjy1Fps1lflKHgPCr5sjXm
YdV4W+LW9Q+ZVkzP51ro4I2gEgw3ev7tBuCuv9HLT8PoKGk+ZeZzwScbl3PyRyOW
OlkW9G2syjo8BQNiEC1k+RHijwMwVP/YcKUoURDMJRfXax97fzmwLREH9XkyYucu
HxEalGA/ZyFQ67uAuvwNRcwTtz+UIksGUH7m9LG4Axm6dyUzEEIiv9c0xz8IhIHy
ByjKg1OxHxCmz1DCe7rmEzVE04yI7sjfj70qsmT9YxEwgnP7AFntcDyBtHyyHkFL
btGw3wqnLJDy5KTdQEbJNBeQjQyvYvtGwnYQpXBPzOdGMym99N0pqf2eyPRuDa96
CkGpctAVh1xiccvzvrgR3HlC63Af5SxWdYIaed4MRWauNcl7EE5b5Xh8do9D++EZ
E+gd9jjhMP+sQmcrbHH6XM+oBxng2C0PTeAVvt53QOWL5WKbFhgNAUVOkjXw0MW9
VCzfp9FCbu+p+Et/Za8QEQd2ycwsAOO1gOpI+2tvi4E+P7V+1aUry7XSnZh4FAtu
R8oTWnd+rKTiNWSuUxAVQZMeoz0gUB5KDVHTGl0P3wGS6vpW3yi5+wHZO/GDkZIw
UIOfM3BQ5Ctgvc3YjXMz5UHQUYXvppcA7ktQZfRma4qp6qwWzNA=
=hHd/
-----END PGP SIGNATURE-----

--nextPart1661950.8mvZZ1hylZ--
