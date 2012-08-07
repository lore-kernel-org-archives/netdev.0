From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: Re: [PATCH] batman-adv: Fix mem leak in the
 batadv_tt_local_event() function
Date: Tue, 7 Aug 2012 20:50:36 +0200
Message-ID: <20120807185036.GG3891@ritirata.org>
References: <alpine.LNX.2.00.1208072030500.3227@swampdragon.chaosbits.net>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature"; boundary="bFsKbPszpzYNtEU6"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>,
 Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>,
 "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Jesper Juhl <jj-IYz4IdjRLj0sV2N9l4h3zg@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1208072030500.3227-h2p7t3/P30RzeRGmFJ5qR7ZzlVVXadcDXqFh9Ls21Oc@public.gmane.org>
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


--bFsKbPszpzYNtEU6
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Aug 07, 2012 at 08:32:34PM +0200, Jesper Juhl wrote:
> Memory is allocated for 'tt_change_node' with kmalloc().
> 'tt_change_node' may go out of scope really being used for anything
> (except have a few members initialized) if we hit the 'del:' label.
> This patch makes sure we free the memory in that case.
>=20
> Signed-off-by: Jesper Juhl <jj-IYz4IdjRLj0sV2N9l4h3zg@public.gmane.org>

Acked-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>


Thank you very much Jepser!


--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--bFsKbPszpzYNtEU6
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iEYEARECAAYFAlAhY3wACgkQpGgxIkP9cwdFfwCeLDF4mxfR3nqQFSugsswE1ABb
pfoAn1pozRGK5vdweqEYCEq63VXelh37
=QOsH
-----END PGP SIGNATURE-----

--bFsKbPszpzYNtEU6--
