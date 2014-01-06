From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 6 Jan 2014 15:35:40 +1100
Message-ID: <20140106153540.179f4fb01293599f5b5099ba@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__6_Jan_2014_15_35_40_+1100_Kurqa2Paerr4wb7L"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Li RongQing <roy.qing.li@gmail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__6_Jan_2014_15_35_40_+1100_Kurqa2Paerr4wb7L
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/ipv6/ip6_vti.c between commit 469bdcefdc47 ("ipv6: fix the use of
pcpu_tstats in ip6_vti.c") from the net tree and commit 8f84985fec10
("net: unify the pcpu_tstats and br_cpu_netstats as one") from the
net-next tree.

I fixed it up (I just used the former version which removes the code
modified by the latter) and can carry the fix as necessary (no action is
required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Mon__6_Jan_2014_15_35_40_+1100_Kurqa2Paerr4wb7L
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSyjKgAAoJEMDTa8Ir7ZwVzysP/0RXqG5LoSTwd/7tzGQPjTqS
knndAW+XqVL3sjFi+wM1iOQQ0bDCUqcWL02kSE2rh8i+Z6sU8VunLv/7BzOxMKX2
RitfRDlp9j3OI5jvEwDhLdF9kCXtNbIECbp0E1OuGc7VrZk8Rq5r07XWhZRsUe8e
ll13BrbgA9eytz3leTNp4kcO4lcsVLifBZgJEnWTx8veM+j3+VSJTk2Hwx1BojbP
pTxnJ8uzcDtFhJmrB9Fiu57ZS2FP2o9Z/5+xMAPOljxSvcOONYHLwgHgbTxdQNpi
4+Lgf24A6LY8aRCACAWLZ57kSZwSUyWsbo8nLTUIzRKZwEvydwCRhDEwBy8wXx3f
TpcHZpvPk2UvrmULmldPeHAY2Qn8uqGOSgPW5DwCoM6zwJbEArgQ//RMUSHJT1oi
VTYdVWu0vpzjDY4mqkMgMlnmpIVqXHBaXs0+nVYzV698qmZBhmuNrl5Ibq/VHgxA
Eh/gXSO06hwHZoq50M6oQ9t4Gcytg2Y8imdZUR1PoCG8r5JfReyYvAmNG/5TETjW
3TP/WKP51CyzJMiCJLUwNMnyciLERpzvtuCtUtJS3XKxLfonBZsww7VCWtJ861cy
cLAbXAMuTJTAhyXz0WPUV2HMbZeZYlLy4rpWj62KwwOVtB0k5fMMmqWq530em3z+
1g6H38lbsLgwIOpoWq4I
=ZOvz
-----END PGP SIGNATURE-----

--Signature=_Mon__6_Jan_2014_15_35_40_+1100_Kurqa2Paerr4wb7L--
