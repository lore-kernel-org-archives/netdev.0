From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 25 Mar 2014 13:04:47 +1100
Message-ID: <20140325130447.e38f4242c03090fd48eae340@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__25_Mar_2014_13_04_47_+1100_q5Yz5lBu0t/4cwzT"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Li RongQing <roy.qing.li@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__25_Mar_2014_13_04_47_+1100_q5Yz5lBu0t/4cwzT
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/core/netpoll.c between commit c27f0872a344 ("netpoll: fix the skb
check in pkt_is_ns") from the net tree and commit 9c62a68d1311 ("netpoll:
Remove dead packet receive code (CONFIG_NETPOLL_TRAP)") from the net-next
tree.

I fixed it up (the latter removes the code fixed by the former, so I did
that) and can carry the fix as necessary (no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Tue__25_Mar_2014_13_04_47_+1100_q5Yz5lBu0t/4cwzT
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTMORGAAoJEMDTa8Ir7ZwVotYP/RQ/etjEXxXCbXOlSgp55ENy
M4VOBwdGomaZA4n8Kz4fX2XrI7CLLT/vW0xWaVt+8GMeSXLFQXu6sgK63o7pTDL+
oXgbt8AOyVc7qDs0ApwIZWI3jOJO5oGZpNBEvT/zXqwOcJsnJKrEa70CWnKEM1CM
p1OBXJsy0w+3kczOZiMZ2mf6c7dwrRbSwFVEeWeWaVs6oCCpQ85AP85p9pFVMft3
5ie7pl3nH/hs5FY1i/6ssaUb6DNE/HYCRkueVh3t4mZ2HJt+iQz0n1ubM3fmyD6F
E8yp1GA9Zpch4zmDRLJ8L9ZPaRS60lY4E0avAzoMuO1IrszzYGX9pIFp2Fb+A0UM
Dy+i8hPdjiLLwu2ZfMvoRxb2pXfLD32061VrIP0z+/j6wGm86bFsefrbaZ9y4tQ+
K4L4Eh66yQPzVkxzfXYe2HAsXUT3kFek799eu5PZqGjiGgkubQ+ypqMnh3nEHRSV
QPI0M8Uj/LVHZU8eTj3GVmDJ6glNMGjTEsAHXVOyPnPNKgfW0kVq/GYFWw6oEkP4
U9HYHL0LDeDJiRsogZPUkm7PnyUFLf59o2JcjC5OvoF8im+FOsMKrrgXHaUiuwHa
91XlreOQ0mHBAaQvM6YxYLuTvxfFVdcGiUb0Fb9TjeqIyA2oTIZADw04YAeW/hZV
MM1+rBqav0bon/Y1UaQm
=gQcs
-----END PGP SIGNATURE-----

--Signature=_Tue__25_Mar_2014_13_04_47_+1100_q5Yz5lBu0t/4cwzT--
