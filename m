From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net tree
Date: Fri, 15 Oct 2010 11:38:54 +1100
Message-ID: <20101015113854.ae080284.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__15_Oct_2010_11_38_54_+1100_PC7O/14KhnYCC3Kf"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Emil Tantilov <emil.s.tantilov@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__15_Oct_2010_11_38_54_+1100_PC7O/14KhnYCC3Kf
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net tree, today's linux-next build (x86_64 allmodconfig)
failed like this:

drivers/net/ixgbe/ixgbe_main.c: In function 'ixgbe_configure_dcb':
drivers/net/ixgbe/ixgbe_main.c:3377: error: implicit declaration of functio=
n 'ixgbe_dcb_check_config'

Caused by commit f32f837b75233588cd4f8542214a30915ab7847b ("ixgbe: remove
unused functions").

Grep is your friend :-)

I have used the net tree from next-20101014 for today.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Fri__15_Oct_2010_11_38_54_+1100_PC7O/14KhnYCC3Kf
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJMt6KeAAoJEDMEi1NhKgbscFoH/0aZ35n2FM6LdZKC5CHCCEcL
1kb//TFxADVYW3gwoAx7YbEXtccslfSEmKmVzKZsy8stTYWIcRE/jpyjkjwJH7Pl
Q419TlSHYEMhFTTikRhzVesZh3HCe5WpOVOBssdzBBUDxGsO2kxgfaB0wsk+5W2r
qivwFf7gTYKZQqGKxbxC5NxOH9PpgWykMQcfoZyp/RRl8fpWyyrWmbz8EO4vP1Ub
OpIGhIkabqqkCWxchJFBW9y4+bNbPEAvZguoVuvSKU1iEPhPRZ+ySNOwOid5hy04
vbYsZ7PzS97cdzIN/n9UWUl0rYcRCwk86+k+wfGMW9Gek1c9ojTrsB8mgF1n5BU=
=ItxM
-----END PGP SIGNATURE-----

--Signature=_Fri__15_Oct_2010_11_38_54_+1100_PC7O/14KhnYCC3Kf--
