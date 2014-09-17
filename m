From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: [B.A.T.M.A.N.] [PATCH 09/22] batman-adv: Replace strnicmp with
 strncasecmp
Date: Wed, 17 Sep 2014 08:00:42 +0200
Message-ID: <5419238A.8030001@meshcoding.com>
References: <1410900696-6481-1-git-send-email-linux@rasmusvillemoes.dk> <1410900696-6481-10-git-send-email-linux@rasmusvillemoes.dk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="SOcx18Pxa3dtFqOhd25HGjq8DjMx6bgaw"
Cc: netdev@vger.kernel.org,
	Rasmus Villemoes <linux@rasmusvillemoes.dk>,
	linux-kernel@vger.kernel.org,
	Marek Lindner <mareklindner@neomailbox.ch>
To: The list for a Better Approach To Mobile Ad-hoc
	 Networking <b.a.t.m.a.n@lists.open-mesh.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1410900696-6481-10-git-send-email-linux@rasmusvillemoes.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--SOcx18Pxa3dtFqOhd25HGjq8DjMx6bgaw
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 16/09/14 22:51, Rasmus Villemoes wrote:
> The kernel used to contain two functions for length-delimited,
> case-insensitive string comparison, strnicmp with correct semantics
> and a slightly buggy strncasecmp. The latter is the POSIX name, so
> strnicmp was renamed to strncasecmp, and strnicmp made into a wrapper
> for the new strncasecmp to avoid breaking existing users.
>=20
> To allow the compat wrapper strnicmp to be removed at some point in
> the future, and to avoid the extra indirection cost, do
> s/strnicmp/strncasecmp/g.
>=20
> Cc: Marek Lindner <mareklindner@neomailbox.ch>
> Cc: b.a.t.m.a.n@lists.open-mesh.org
> Cc: netdev@vger.kernel.org
> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>

Acked-by: Antonio Quartulli <antonio@meshcoding.com>

Thank you



--=20
Antonio Quartulli


--SOcx18Pxa3dtFqOhd25HGjq8DjMx6bgaw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUGSOOAAoJEJgn97Bh2u9eVvMQAJVCB7XfWcFSKT4CaiV5BIf9
FmoWMmk0GFHOOhjCzmBSPZ0OY62r75rleJBfd8j4gCpJZnrekX6RODUf1OGK9U2q
DnQjTdPVneI3EM72c9v7tQBH+HWsMffPX7xIAfHpUXNbSH97860tdddAIMBVAf3I
ESEPOTwW/Nz1DnAI8/qVzErJAo28/BNjCL/19pwjmudj4AgTx8IxmXyAdGW+Kib6
NvBGMt7Wh528yatvh/VrcFRr14XgFZHFYXkKXBEtYFW/Vu/TbxXsZIunk9if61On
noV1isZ2o73+/kucMfjSWfciMyaDEwZCqTVEv57DVeSNkJ8bC3f8tx5ad8GDL7UF
bvR7XV+mKZAJiA0rH0KS+Pof1l9l6fdQxqtw0yPSKm3T3vCXvz+9F2Axk4ievd7C
Zuy5z46PLnO2ZzX3W6bgjYAkEA/cXvn+DM7j/03Rcn6RqCbRHLofsyPfNnFAuUvN
3/YC2nxjilogX9bi1Wx3s05hZdUNqboxLzby0mOMo8oHxR/TTWjKi68HZ7YG8UiD
Rg1GNJc/8/KmFCZuYKXZYjPkEj1kJ/8sgovSLHytJ2Xqb35GWmkRpcDemO+VGB/H
a8BkB8IsdrncBRRpgPvoBNAkujJKPg4WENPB2ORumrLNBMjXDdk9IkkK1b9SBPWm
Oi5cA2z0uaoNw5HwBRrI
=sDAN
-----END PGP SIGNATURE-----

--SOcx18Pxa3dtFqOhd25HGjq8DjMx6bgaw--
