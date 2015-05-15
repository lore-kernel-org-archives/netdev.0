From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the rcu tree with the net-next tree
Date: Fri, 15 May 2015 15:25:43 +1000
Message-ID: <20150515152543.564caf94@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/0ewa5YAdD4k+X7BaNI7OO_5"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Patrick Marlier <patrick.marlier@gmail.com>,
	Pablo Neira <pablo@netfilter.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/0ewa5YAdD4k+X7BaNI7OO_5
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Paul,

Today's linux-next merge of the rcu tree got a conflict in
net/netfilter/core.c between commit f7191483461c ("netfilter: add hook
list to nf_hook_state") from the net-next tree and commit e4dcfe3a648b
("netfilter: Fix list_entry_rcu usage") from the rcu tree.

I fixed it up (I used the net-next tree version) and can carry the fix
as necessary (no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/0ewa5YAdD4k+X7BaNI7OO_5
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVVYNcAAoJEMDTa8Ir7ZwV2FIP/0bTgE/OSV3YjQPgBhqs+NRE
MTCEjGljJ7NPI9BbEEItpvNoHJaZnhaAhL1hbOM7+S7W9BpCIjh7cQy6dQiHdv4a
TbMHCyly1RvlOMRUMPsH9D4SaIlHZS6XB4tQz3h+z7os5YsIbTARe7d2NYIz0UTc
RFcJlC0GIpxqmZacLanbLvRkdhdtrE7PoyJ5UhaEIW5uwmQuHCw4Gn0f8G3fdQhm
Fy30k/5gG3Usk8yqxTyGwhxUOgsTViLK1MkAZLbPoeiStayjO7M9PLmrorZ+1Uri
jRavkOD4hpuhkeMRVFAHNnoYjhHkPegLCdBjscaaxftGL9Y+hPmYTrztY1HlSSmJ
B444RyJoNmFcz9jAiInusERi25oXVjp4i7kxnbip5Uly2/i8npGN8BMib5y5AkIQ
QQNz+o+3ejWZzX0fpj4zFRyez97s2+0ZVYP/OAW1D4+PedTb6BhTFE/4r7tj2OYY
aNAiXjHr3nbfN76Q14HFI4r2B5qGa7A9cT3Imm1OeJu3Jo5PrhgduLl3UvWt6Fki
sKd+wzBN2Fv48N9remzeUodp+VmKGsGPDK0pff62ClnC0e+iBZo74/fwpLEn8fue
eZAlm7pgzl+ashHpVDnPqWBjRI68ObObb22puwML1TAn4DHgxpUZ1maboO1HJYez
0cWQyv07Kh4HUWg4+CCS
=UHQ1
-----END PGP SIGNATURE-----

--Sig_/0ewa5YAdD4k+X7BaNI7OO_5--
