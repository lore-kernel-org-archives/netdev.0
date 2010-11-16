From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net tree
Date: Tue, 16 Nov 2010 11:34:37 +1100
Message-ID: <20101116113437.4f536d16.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__16_Nov_2010_11_34_37_+1100_S6.xhMdE8Vnkven9"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__16_Nov_2010_11_34_37_+1100_S6.xhMdE8Vnkven9
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net tree, today's linux-next build (x86_64 allmodconfig)
failed like this:

ERROR: "netif_get_vlan_features" [drivers/net/xen-netfront.ko] undefined!

Caused by commit 58e998c6d23988490162cef0784b19ea274d90bb ("offloading:
Force software GSO for multiple vlan tags").

Presumably netif_get_vlan_features needs exporting.

I have used the net tree from next-20101115 for today (with
1d7138de878d1d4210727c1200193e69596f93b3 reverted).
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__16_Nov_2010_11_34_37_+1100_S6.xhMdE8Vnkven9
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJM4dGdAAoJEDMEi1NhKgbsyxoH/2wyVT7rK8tXez1gGOCTkBN/
PA6XMcZo1B3K8Olch+SSlkKet9GyK8sRpwUKgrz03tKxUw56HVI5hq/qsXeH+4xp
kpgpz5bz05oFvhuJAAna03DtKwz3rd65jK+dfMwjto0zMEcE3bMvFvtaBnJeiEzb
6Y+Crws6FcbfC8Kc9eaIO5+sKosySAgd6AHc36IkPORBRhW+Wkl4ew/hrrVQMjOJ
clSsZ0rRkZPK7TpuOjYqsB9aStVloJWwO2xrA4CiNifLVz2BZfEnx5MF9iyFORWg
o9+g/skHfZ8kpqQbrrnIkqOQmSC5DhTNIsfjdLDX1svHUQqKUvRqduGNfLACS0g=
=8C/n
-----END PGP SIGNATURE-----

--Signature=_Tue__16_Nov_2010_11_34_37_+1100_S6.xhMdE8Vnkven9--
