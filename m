From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build warnings after merge of the net tree
Date: Wed, 16 Jun 2010 13:38:54 +1000
Message-ID: <20100616133854.1bbbbb37.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__16_Jun_2010_13_38_54_+1000_mlmjYNNFlOR/cK6T"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__16_Jun_2010_13_38_54_+1000_mlmjYNNFlOR/cK6T
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

After merging the net tree, today's linux-next build (x86_64 allmodconfig)
produced these warnings:

In file included from drivers/usb/gadget/ether.c:123:
drivers/usb/gadget/rndis.c: In function 'gen_ndis_query_resp':
drivers/usb/gadget/rndis.c:197: warning: assignment from incompatible point=
er type
In file included from drivers/usb/gadget/multi.c:67:
drivers/usb/gadget/rndis.c: In function 'gen_ndis_query_resp':
drivers/usb/gadget/rndis.c:197: warning: assignment from incompatible point=
er type
In file included from drivers/usb/gadget/g_ffs.c:30:
drivers/usb/gadget/rndis.c: In function 'gen_ndis_query_resp':
drivers/usb/gadget/rndis.c:197: warning: assignment from incompatible point=
er type

Introduced by commit be1f3c2c027cc5ad735df6a45a542ed1db7ec48b ("net:
Enable 64-bit net device statistics on 32-bit architectures").  This is a
call to dev_get_stats() and the return value is being assigned to a
"struct net_device_stats *".

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Wed__16_Jun_2010_13_38_54_+1000_mlmjYNNFlOR/cK6T
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkwYR04ACgkQjjKRsyhoI8wLqACfTy3XaBsmvmBUChhuf1XeTze0
ZKMAoK+heaf5UztEnxGlCaIER9q937RZ
=y7pG
-----END PGP SIGNATURE-----

--Signature=_Wed__16_Jun_2010_13_38_54_+1000_mlmjYNNFlOR/cK6T--
