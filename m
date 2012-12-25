From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: Re: [PATCH 19/29] batman-adv: fix random jitter
	calculation
Date: Tue, 25 Dec 2012 12:26:57 +0100
Message-ID: <20121225112657.GC2604@ritirata.org>
References: <1356315256-6572-1-git-send-email-akinobu.mita@gmail.com>
 <1356315256-6572-20-git-send-email-akinobu.mita@gmail.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature"; boundary="NDin8bjvE/0mNLFQ"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>,
 akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>,
 "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Akinobu Mita <akinobu.mita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1356315256-6572-20-git-send-email-akinobu.mita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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


--NDin8bjvE/0mNLFQ
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Dec 24, 2012 at 11:14:06AM +0900, Akinobu Mita wrote:
> batadv_iv_ogm_emit_send_time() attempts to calculates a random integer
> in the range of 'orig_interval +- BATADV_JITTER' by the below lines.
>=20
>         msecs =3D atomic_read(&bat_priv->orig_interval) - BATADV_JITTER;
>         msecs +=3D (random32() % 2 * BATADV_JITTER);
>=20
> But it actually gets 'orig_interval' or 'orig_interval - BATADV_JITTER'
> because '%' and '*' have same precedence and associativity is
> left-to-right.
>=20
> This adds the parentheses at the appropriate position so that it matches
> original intension.
>=20
> Signed-off-by: Akinobu Mita <akinobu.mita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Cc: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
> Cc: Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>
> Cc: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
> Cc: b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
> Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> ---

Acked-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>

But I would suggest to apply this change to net, since it is a fix.

Cheers,


--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--NDin8bjvE/0mNLFQ
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBAgAGBQJQ2Y2BAAoJEADl0hg6qKeOBO8QAL3lkJA82Hk1Co++znzd9nEl
0yr21UdyxPqhhlVACD+EX1pcFt2QC4Gm5yD6Mu/g2UA9GCBuz2PCHQfc8GR/xoIn
U0e14nug3oe9az4gfhWdkyYe3CzYVhDz+qWeazM+qzdZK/WVluQ/uy2hh5LUnkve
XPN6q9DwwoSW8fFLSMxhWZ1cSsvTk6cWArUAGyLEuF5c+w3PKvzKLK2oZcUFWqvR
+iW52Y7W8m9gbivRavq570ZsDWh248wzTm1qIsWknpFpORWaU47gt8XEpMuhGdJG
WjKIC5LzsTtQxwCSoF5zIczxBE7WgoCUUbUHXgA5PUkX2NWSdUw0LB0O513TySIo
7joXIFDpfu1R2w8YQWPEnKOfYeE/jDf2zJBgI+LnKViDUhPL2otfjB183ljlmFnl
KQHBrhDA8mqCCe3l5SOtdrTpDXBniWnOaAEgdb5aCINGRn5XCba3fH9Gn+ENN6GD
JAuOxNojJDX1mv2IB1CO9afJhOknqflgDF5FBoZdYHyM5VwZntrQllNIk+z/9T2n
OWTDWKVbNWAHvQ+dniSnfdAjitlOL98t/n7KfpUv1aOwK6jHssbqUnJRLbzN1dSU
VnjOaiAGhhDJvdeJ0xEgkjdfecfHVxmpyrFVi1cdfMQX9//c7iXFqjH0TC+U8FBz
7Z3FqJfifdNAJ4OG7g6c
=hU8U
-----END PGP SIGNATURE-----

--NDin8bjvE/0mNLFQ--
