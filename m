From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the akpm tree with Linus' tree
Date: Mon, 26 Nov 2012 23:48:44 +1100
Message-ID: <20121126234844.1952cdd84c3ba041cfe7a9af@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__26_Nov_2012_23_48_44_+1100_GmJ.OBQ7wz9vv9oM"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Xiaotian Feng <xtfeng@gmail.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from haggis.pcug.org.au ([203.10.76.10]:40545 "EHLO
	members.tip.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753767Ab2KZMss (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 07:48:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Mon__26_Nov_2012_23_48_44_+1100_GmJ.OBQ7wz9vv9oM
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

Today's linux-next merge of the akpm tree got a conflict in
drivers/net/ethernet/jme.c between commit 71c6c837a0fe ("drivers/net: fix
tasklet misuse issue") from Linus' tree and commit  "tasklet: ignore
disabled tasklet in tasklet_action()" from the akpm tree.

I am not sure what to do here, so I have dropped the akpm patch.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Mon__26_Nov_2012_23_48_44_+1100_GmJ.OBQ7wz9vv9oM
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQs2UsAAoJEECxmPOUX5FEissP/Al9ZrIlDPMjIp6WX0sj1ETj
8BeVeNkdwwdxrsc8JvzV5Wt2bSZv5KEiFPLOHGF/dKqho1BDgW5BX/cNYN6XixZt
NavUJcoIJ6Uv9qhlvDyoRc9k7No2BQ425jeE9QdbnXw6Vo3T7txFYpZo4Sg43R+c
KVKIhdZovIsI0JTZxmG/nHEQouHFnttnw6z1XG32iU3KzrW8DaKHpJ9xnl1pJWwp
CNRIPvDjcC7rBxFGC0vlrrEyWeQI+u4Q99YvvCydVOCUKDvEjLURAcGprUJDy5PB
DXhsYHopTpi+pmzUqtwb7u8NHutR/5UTullc8kp20xwnWlZXnk1YRB206BPq3t1X
DD6VTx0yEkEH+KmrbgYpJNURgpfzhDd/YRFJgej+uhTWQfgFBohrIB0rlMk0NmII
RDZNb9I3VyXLwO9RiymSBMcyKzbDmMm9+LeVlLrP19SIXxCUcNgQH+hv6aqtgoJs
djCjxcgnwX1yY0NiCXke3Vy0shpQHZn3W4oKekvTllYTYoOi+IjKvyE+Mo0DJ4M/
F0dhVNniYsSw7/uMNdr5lSrT0QyeYhtRNApda2kgKA9SsL/PRq/9ZKTqXhdW3fq1
czS+oMNBI+5mYk/8Ke+GQ7RjWAGxrL8DIQRt7BeTOS3DrWLS+XEOPy06I+uj1Pkn
y8t9XNyIl2WJ5g/QQIpJ
=VdPw
-----END PGP SIGNATURE-----

--Signature=_Mon__26_Nov_2012_23_48_44_+1100_GmJ.OBQ7wz9vv9oM--
