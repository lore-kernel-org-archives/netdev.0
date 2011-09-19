From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the final tree
 (origin/net-current tree related)
Date: Mon, 19 Sep 2011 18:35:49 +1000
Message-ID: <20110919183549.765331241abb61e22418c69a@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Mon__19_Sep_2011_18_35_49_+1000_2QaP+yoH_MpDWJdP"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__19_Sep_2011_18_35_49_+1000_2QaP+yoH_MpDWJdP
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the final tree, today's linux-next build (powerpc
ppc44x_defconfig) failed like this:

net/built-in.o: In function `tcp_v4_conn_request':
(.text+0x5b700): undefined reference to `cookie_v4_init_sequence'

This error has already been noted elsewhere and a fix queued, so I have
merged a newer version of the net-current tree that contains the fix for
today.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au


--Signature=_Mon__19_Sep_2011_18_35_49_+1000_2QaP+yoH_MpDWJdP
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJOdv7lAAoJEDMEi1NhKgbs3uMH/jiyx+cofZaeUngnozLvDZ5R
MURSeHqgCsEsl6s2GTqd1xlcm2FVvXCdG3jJkrKTGoMc7fiEqEEc19sD3fLsEl33
aU0MHhhHbGDjNhdprevx3Xh2Hm8LPapFvNd6M7MmmJZzrYYQ9LFtgWAx/OKJy6QN
NWLnJJeEoe0kHa3rwC7t6hvqv2cG/rXeE9J49mFGBAXRbn5K5MzL7BO/gJRPJbdB
YBDcn0Pfonn7jtqFFktMyO5D+n7xzSURoY7SF46klZFcPnn8qwguHUnTRKRj19cE
iC6XNtS/2F9d5fEuWDD4q9QkdXB/e3fSMzjyCmV9i6LzzNxpqnqXHQo2emLFO98=
=0ugA
-----END PGP SIGNATURE-----

--Signature=_Mon__19_Sep_2011_18_35_49_+1000_2QaP+yoH_MpDWJdP--
