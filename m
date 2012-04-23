From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build warning after merge of the net-next tree
Date: Mon, 23 Apr 2012 16:54:09 +1000
Message-ID: <20120423165409.d424daced95611012d151aa6@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__23_Apr_2012_16_54_09_+1000_HUWtHaC8wXxhQHv+"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__23_Apr_2012_16_54_09_+1000_HUWtHaC8wXxhQHv+
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net-next tree, today's linux-next build (powerpc
ppc44x_defconfig) produced these warnings:

net/ipv4/tcp_ipv4.c: In function 'tcp_v4_init_sock':
net/ipv4/tcp_ipv4.c:1891:19: warning: unused variable 'tp' [-Wunused-variab=
le]
net/ipv6/tcp_ipv6.c: In function 'tcp_v6_init_sock':
net/ipv6/tcp_ipv6.c:1836:19: warning: unused variable 'tp' [-Wunused-variab=
le]

Introduced by commit 900f65d361d3 ("tcp: move duplicate code from
tcp_v4_init_sock()/tcp_v6_init_sock()").

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Mon__23_Apr_2012_16_54_09_+1000_HUWtHaC8wXxhQHv+
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJPlPyRAAoJEECxmPOUX5FE+FsQAJiexwxIEC6Owvq46O8Hafqx
kIGXubjiuvsGo0BXk4Q1smUbsrTsEMYhFcOYpkEbC4dADV4yXnUMSBhnqXTZYuD+
gaNxGJKObviWGOe79GLr90ckmFQRs0/GcGbzYPTD+giErCaVNAcXHZU8hyoMnmcd
ndIl0OZfDRu8Sp7PnOvJhx8iaAsvwdyORxO139bM84wYtnvBQhRhzmAopvN3P1Z4
OAbloQipSST4yi6uqyea4DAgZN7OYLanv8tSyh7r+1TS0qfi3dqwDcnCJppbnxdJ
Db1oPjDOIWAegJxRBCMsXannbZx1cQZXshy8jg7myUMlLTY2rljqAWIS0DmcuJYB
yH6UKfWqnKmOR7PPACNghuWu9dAqAn/mAJELB2L6XH1mETlVe7GXeBnZltgfU2fb
xwZXFIClMAQSAHUzvT1oWUyDp9qAEtBQxbI1eaerz/FrPHgw+IHMTfgqN6+W3aQK
UUnnNL2IKxtddJH/T/dNvAvcx79aw1/6idMLe6VkNCqQJXMxg/xdqqp39YukBmty
3mMAvRKXqaEdNeX2RNQwlZWEGY54R6AR1gMEDSvFqZn+sdnPlHUZZ55u8VgMKlFV
kZYUj+Ri5eAYMW5h7QrgD/xXUlY4jFfM4Cb+4v7hAcsC6LjmVr+EbfdNURtO+Hke
r30/4BAx6BVhYj3KJTNI
=L1B2
-----END PGP SIGNATURE-----

--Signature=_Mon__23_Apr_2012_16_54_09_+1000_HUWtHaC8wXxhQHv+--
