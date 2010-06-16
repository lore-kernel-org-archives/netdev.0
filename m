From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build warning after merge of the final tree (net tree
 related)
Date: Wed, 16 Jun 2010 13:48:48 +1000
Message-ID: <20100616134848.3edd4a25.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__16_Jun_2010_13_48_48_+1000_6znWOPAIaCPcEy.j"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__16_Jun_2010_13_48_48_+1000_6znWOPAIaCPcEy.j
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

After merging the final tree, today's linux-next build (powerpc
ppc44x_defconfig) produced this warning:

net/bridge/br_forward.c: In function '__br_deliver':
net/bridge/br_forward.c:76: warning: passing argument 1 of 'br_netpoll_send=
_skb' discards qualifiers from pointer target type
net/bridge/br_private.h:308: note: expected 'struct net_bridge_port *' but =
argument is of type 'const struct net_bridge_port *'

Introduced by commit 91d2c34a4eed32876ca333b0ca44f3bc56645805 ("bridge:
Fix netpoll support").

By the way, that function (br_netpoll_send_skb) is only used in that one
file, so could be static in there.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Wed__16_Jun_2010_13_48_48_+1000_6znWOPAIaCPcEy.j
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkwYSaAACgkQjjKRsyhoI8z1EACgjvxDGfxcBf+enX5IIF9T3wa9
7cgAoKXwB0Cs6nyaWDuMh2d2vZEK1C+Q
=mDz+
-----END PGP SIGNATURE-----

--Signature=_Wed__16_Jun_2010_13_48_48_+1000_6znWOPAIaCPcEy.j--
