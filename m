From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build warning after merge of the  tree
Date: Mon, 29 Mar 2010 10:31:39 +1100
Message-ID: <20100329103139.1a735227.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Mon__29_Mar_2010_10_31_39_+1100_eU/Go2RH0Y3.wc/8"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Kyle McMartin <kyle@mcmartin.ca>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__29_Mar_2010_10_31_39_+1100_eU/Go2RH0Y3.wc/8
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

After merging the  tree, today's linux-next build (x86_64 allmodconfig)
produced this warning:

drivers/net/tulip/uli526x.c: In function 'uli526x_rx_packet':
drivers/net/tulip/uli526x.c:861: warning: assignment makes pointer from int=
eger without a cast

Introduced by commit ac90a149361a331f697d5aa500bedcff22054669 ("tulip:
Fix null dereference in uli526x_rx_packet()") from the net-current tree.
There is a missing set of parentheses around an assignment in an "if"
condition ...

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

P.S. this commit is missing a SOB from its purported author

--Signature=_Mon__29_Mar_2010_10_31_39_+1100_eU/Go2RH0Y3.wc/8
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkuv5twACgkQjjKRsyhoI8x5KgCggaEJRvfY3KrgLu6TrFlxmxUn
5tsAn0/9aCZzGwJs7XcgcU9RT8MkMi4C
=0pfd
-----END PGP SIGNATURE-----

--Signature=_Mon__29_Mar_2010_10_31_39_+1100_eU/Go2RH0Y3.wc/8--
