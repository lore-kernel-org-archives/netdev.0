From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with Linus' tree
Date: Wed, 26 Sep 2012 11:46:21 +1000
Message-ID: <20120926114621.a512573023db025b3746a7e0@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__26_Sep_2012_11_46_21_+1000_DXbEt2jh7v6r/wCb"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	=?UTF-8?B?IkxpbnVzIEzDvHNzaW5nIg==?= <linus.luessing@web.de>,
	Antonio Quartulli <ordex@autistici.org>,
	Sven Eckelmann <sven@narfation.org>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from haggis.pcug.org.au ([203.10.76.10]:36886 "EHLO
	members.tip.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750824Ab2IZBqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2012 21:46:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Wed__26_Sep_2012_11_46_21_+1000_DXbEt2jh7v6r/wCb
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/batman-adv/bat_iv_ogm.c between commit 7caf69fb9c50 ("batman-adv: Fix
symmetry check / route flapping in multi interface setups") from Linus'
tree and commit bbb1f90efba8 ("batman-adv: Don't break statements after
assignment operator") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/batman-adv/bat_iv_ogm.c
index 469daab,df79300..0000000
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@@ -642,9 -652,9 +652,10 @@@ batadv_iv_ogm_orig_update(struct batadv
  	struct batadv_neigh_node *router =3D NULL;
  	struct batadv_orig_node *orig_node_tmp;
  	struct hlist_node *node;
 +	int if_num;
  	uint8_t sum_orig, sum_neigh;
  	uint8_t *neigh_addr;
+ 	uint8_t tq_avg;
 =20
  	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
  		   "update_originator(): Searching and updating originator entry of rec=
eived packet\n");

--Signature=_Wed__26_Sep_2012_11_46_21_+1000_DXbEt2jh7v6r/wCb
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIbBAEBCAAGBQJQYl5tAAoJEECxmPOUX5FENH4P+IYb4SuWD2H1L3ee8vUCeZKK
TdDMugWQtNd+1INDva7Xj9AhUAgdiG6HFUCXvmKkVHIXqVych0f3EpdQE9B56x6F
ad0jPJYg8DosGCvm2SuLQEftdDNy/MIERiwqZpbLcQAEmN++3igB8ko/n5/CJSgK
O7Fhb0uhEBb4s3rjxdP+1o1jzoxo1VJSMBBeUguSFreR45ZBFuKXLdCfqrDqp9vr
e9VhmUJRDp8m07SiJs2twjPfPFsSb7pE7PtGGZaZg6lq1EKIF0/17w/VrQwoPgP1
whViSxYskYSgEZz4z8VxfZVlCbPLOAFpnq+FGD8Fzn581pdM3ipS6+sXpvT8IFZ/
UdlXJuEBnNLDk2jwfqxJs0KmcOMvGVkl7WLYS4WuFj/O0fUc2DFej9Gon9ZbP2ow
b43W9JL9sTBgNsv+TXMqAWdS/XxoqpvSzeohn2MC7fOydFyBPQLZEIjJ+i0ZOuPr
p+ZyHuUwc/yXUh2yKXo945Z4QHHz2FejyMmnZq4FCIZa6gVM0a2r9qP1kTWuXhaf
g1RkW1K2rAawBVIcphwdWPfjtoz5psQ7CRXQPmLx//DR0TBgaK4P2Xsa/KpiTWe6
VOuHxn/X/iJlMGjjfkXY19wmzvKbqfmSk5S/ug4qNJcgzE/5uPeY2vXNtaNQ20lC
ScLHN5Oly8BpF54eVA0=
=DNXs
-----END PGP SIGNATURE-----

--Signature=_Wed__26_Sep_2012_11_46_21_+1000_DXbEt2jh7v6r/wCb--
