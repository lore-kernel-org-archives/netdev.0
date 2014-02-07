From: Christian Engelmayer <cengelma@gmx.at>
Subject: [PATCH] 6lowpan: Remove unused pointer in lowpan_header_create()
Date: Fri, 7 Feb 2014 22:58:38 +0100
Message-ID: <20140207225838.18ad2ffb@spike>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/venGtObzij=pRyNabIw_WXO"; protocol="application/pgp-signature"
Cc: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	Jukka Rissanen <jukka.rissanen@linux.intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:54113 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750744AbaBGV6k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Feb 2014 16:58:40 -0500
Received: from spike ([81.217.122.98]) by mail.gmx.com (mrgmx002) with ESMTPSA
 (Nemesis) id 0Lb4vZ-1VW07b1XD7-00kezu for <netdev@vger.kernel.org>; Fri, 07
 Feb 2014 22:58:38 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/venGtObzij=pRyNabIw_WXO
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Commit 8df8c56a (6lowpan: Moving generic compression code into 6lowpan_iphc=
.c)
left pointer 'hdr' unused - remove it.

Detected by Coverity: CID 1164868.

Signed-off-by: Christian Engelmayer <cengelma@gmx.at>
---
 net/ieee802154/6lowpan.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 48b25c0..8bfb401 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -106,7 +106,6 @@ static int lowpan_header_create(struct sk_buff *skb,
 			   unsigned short type, const void *_daddr,
 			   const void *_saddr, unsigned int len)
 {
-	struct ipv6hdr *hdr;
 	const u8 *saddr =3D _saddr;
 	const u8 *daddr =3D _daddr;
 	struct ieee802154_addr sa, da;
@@ -117,8 +116,6 @@ static int lowpan_header_create(struct sk_buff *skb,
 	if (type !=3D ETH_P_IPV6)
 		return 0;
=20
-	hdr =3D ipv6_hdr(skb);
-
 	if (!saddr)
 		saddr =3D dev->dev_addr;
=20
--=20
1.8.3.2

--Sig_/venGtObzij=pRyNabIw_WXO
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAEBAgAGBQJS9VcOAAoJEKssnEpaPQKElvUQAJSzDmc26/MOcZZGRrpjlvAZ
Jn8U1G2rjukiMhRkJK92pOfVW37Uked/eBNaae6Ks5meb4fpvi7EZi3pBnMR5EtY
+JgG6F4C+bxhMjDBTCd6qg31YBKyvwra0XfYOjUI1yGSaOYr88voyDUoDsuoEYWn
6+x6ZhDBYO0J/aCr5xbIidtyhqncXUZVWPEFOrELs3My1qRXh0e/OgaNlBOXizsz
RxtOeZRjejxQtM/0qy962nUqPva83a5r7njhjXY1nA1gL2gpZkPKYNnjHUTDzM7g
0maHBD5NFxc08ReKEZsiK1MQyv7cljlSvA768CzoQpxqh7QnSZl4mpFEDYRttiY2
I0ic1PB2ZdJOPCZAzvEq3NlZmiSVU03INobZAGpGe6utvspmv/rNPIBpl07bu/TC
9XJU0wqPzpEki6jYoIKhjvnptqV5lnzjZd6+f46HfJIGvaJJ32GSTn/cGOzfrpv0
e46sX0bBDXBCI+QQV8y3+HgEkgvGY+KzKc4xg1YS/Jh6FMrMUJYwTtmEiGo/RfnN
4OtU/Xf1JDZkdj77+714/TovXbDqrbb2HllxllgkKKdEtQZI8xrhqhs1anCUzfRc
pkL0LXLZlJXO9IEmdjZhErYVRqgs9zD6yE3Jzbh/sZLhPYF9YGm938+SDX37DpKD
oVaWQPB/QBpFnXiYNdE5
=EvUV
-----END PGP SIGNATURE-----

--Sig_/venGtObzij=pRyNabIw_WXO--
