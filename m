From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the  tree
Date: Tue, 4 Jan 2011 13:28:37 +1100
Message-ID: <20110104132837.cfecc014.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__4_Jan_2011_13_28_37_+1100_gWXQ21Lg=xFmV4ME"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jon Mason <jon.mason@exar.com>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__4_Jan_2011_13_28_37_+1100_gWXQ21Lg=xFmV4ME
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net tree got a conflict in
drivers/net/sky2.c between
commit1d3c16a818e992c199844954d95c17fd7ce6cbba  ("PCI: make
pci_restore_state return void") from the  tree and commit
0f333d10e3f689640b229c8cf00b16ea51ce4951 ("sky2: Do not use legacy PCI
power management") from the net tree.

The latter removes the code that the former modifies.  I used the latter.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__4_Jan_2011_13_28_37_+1100_gWXQ21Lg=xFmV4ME
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNIoXVAAoJEDMEi1NhKgbsgZkH/3XVI6R9d5aru9n36cylHa3U
TMWONd+D1aoEZ1WkIPVIWnrKtPZnieAnXTUdSaLYZtmjDburZwYldUxR5O7kdy5y
dDku/M5u6X2PPM4iuVJXeaGcdXAQwdDAbth0z9kQ6zJKi4kAApFg62R0ettepeXv
hp3bGe+p3Hnym5yds1f6ZsSqSPHhsCDBoI8Wbj+MUIYddfcTM2eAASFIZtKxZ2Lt
H2F+nzeUiNHRuaUsmQ0t1I+ZolvPWb4eh1BrqMZZ2K7GBhxi8OdnuvWgDfchj0xp
QZd/KBiuF11KDA5LYw9Kc4XihipyK/IIJb1VVkGJhdJ/NCeOCw5hC6HAbE668Ss=
=ykR6
-----END PGP SIGNATURE-----

--Signature=_Tue__4_Jan_2011_13_28_37_+1100_gWXQ21Lg=xFmV4ME--
