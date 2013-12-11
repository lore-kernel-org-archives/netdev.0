From: Antonio Quartulli <antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org>
Subject: Re: [PATCH -next 2/3] batman-adv: Use seq_overflow
Date: Wed, 11 Dec 2013 08:31:35 +0100
Message-ID: <52A814D7.1060805@meshcoding.com>
References: <cover.1386738050.git.joe@perches.com>
 <e7104b35287b1e1ec456734c1b5e1aa98dac99f8.1386738050.git.joe@perches.com>
 <52A813C1.8070404@meshcoding.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="bbG9snU5osjWRKo4NB4AAansjRPstJHRd"
Cc: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
 Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <52A813C1.8070404-x4xJYDvStAgysxA8WJXlww@public.gmane.org>
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

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--bbG9snU5osjWRKo4NB4AAansjRPstJHRd
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Joe,

we have other places in the batman-adv code where we use seq_printf, but
at the moment we don't check the return value and we always return 0 at
the end of the function.

I think we could use seq_overflow here as well?


Thanks,


--=20
Antonio Quartulli


--bbG9snU5osjWRKo4NB4AAansjRPstJHRd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSqBTbAAoJEEKTMo6mOh1VQRAQAJ5F+K+L3WKBmDNEm5hDwEqH
QEkP/hoUahL+awpng34XuxE90ci9GksBZfm6kXADZhtqRH1SeXh89D99sX/BKL0N
4POYhXv9Z5NVSfEl0FqEcaidSIKfoHuLXl0vHFNLT+UKnZZ1Hx/RIHF74hcSbCTj
niKhmWEt1OUKmUiQcLz5FKWF6VG1AJL2kT2MISgHHahNEBZDwuOIgjY+unL0MsAS
ClAuSgym5MDoPRcPzARDq7znt1Ql4aOgjo8n5lCymDW/zJ922UHJSU31N4IRkU6R
c4Fsx2AWorasM6PMgma+sUPAZTRdsekDHI1hNPNK3cHuaBLBPBOHD1Bljdc69ILy
rtKcUoW6E8I4P2EzV+p37Eahn+xoNI/mQUV0fIAsRk2fFICKul9urswD33WRBiqs
CaB7twGviBUCpou+Q4AdxQH+Yz50aXRosz1aEjcWSGniVmI1Vll6m+Z4lxLneHzs
LDm0WwLZFxZt1tvb/xnLs/VsIFsS22XEr1VsBb5oEDKSaWcTzEwSCZg8MH/3cy1f
6bE0tGQ8mDiagr/cVizLU6VCSTCt3W9iiOacL8xv8vLI3oR8y/8aWOv/m63EwSbL
KV0Wg+U4mpXo8E/Cc6v+8/W9+V4h2dAUHmXf9/8q675ZXu99hrJl3HaOSSuxaRPx
Or7pQuy6CQNhXL9jaNij
=s7fm
-----END PGP SIGNATURE-----

--bbG9snU5osjWRKo4NB4AAansjRPstJHRd--
