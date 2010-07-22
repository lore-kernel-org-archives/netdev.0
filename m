From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build warning after merge of the net tree
Date: Thu, 22 Jul 2010 12:11:57 +1000
Message-ID: <20100722121157.344c8462.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Thu__22_Jul_2010_12_11_57_+1000_icAvp+NkShx5C8Su"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__22_Jul_2010_12_11_57_+1000_icAvp+NkShx5C8Su
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

After merging the net tree, today's linux-next build (x86_64 allmodconfig)
produced this warning:

drivers/vhost/net.c: In function 'vhost_net_set_backend':
drivers/vhost/net.c:536: warning: label 'done' defined but not used

Introduced by commit 11fe883936980fe242869d671092a466cf1db3e3 ("Merge
branch 'master' of
master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6") which
kept the unneeded label.  Sorry if I misguided you.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Thu__22_Jul_2010_12_11_57_+1000_icAvp+NkShx5C8Su
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJMR6jtAAoJEDMEi1NhKgbsnwQH/j4Fb9LUcVQ/+ST4FIvprO7G
TLE5keUqKQ55pe6Npl8u52SlG41wHzjjVmw16EFWy9zNcbOIWWkjIUFi3PlHuHEb
Crmqz/wiLlDbvwM7qARFE0uwpw6aJa2U4LNSO161lvucuMvk7HFYgMkpKHiGJSUe
gvyZQJbzN7zQeIzONpAU37vXfGdfH473FtwvqricN+P6+3lNOxE2ZyaUc33Xpnq3
GRKkGGKGTfODNV5creopqVU/wnGpFnYTOllGuQNtr+FDxYvb1H8KMAYPiRhkq4+i
w5cXjW02QkHcAuBn9X3ZuSRHEgYRMONgI0Nqzl+eE0sja8AkSyyLLYzGtqy1ySE=
=8Wxn
-----END PGP SIGNATURE-----

--Signature=_Thu__22_Jul_2010_12_11_57_+1000_icAvp+NkShx5C8Su--
