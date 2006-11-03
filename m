From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 5/6] d80211: add a ethtool_ops hardware property
Date: Sat, 04 Nov 2006 00:22:49 +0100
Message-ID: <1162596170.24673.19.camel@johannes.berg>
References: <20061102223854.692274000@sipsolutions.net>
	 <20061102223854.692274000@sipsolutions.net> >
	 <20061102230016.080591000@sipsolutions.net> >
	  <200611031743.15770.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-5AXvT5UiGVQE0iZRn2hV"
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org,
	Ivo van Doorn <ivdoorn@gmail.com>,
	John Linville <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>, Hong Liu <hong.liu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:48318 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S932494AbWKCXYS
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Nov 2006 18:24:18 -0500
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200611031743.15770.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-5AXvT5UiGVQE0iZRn2hV
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2006-11-03 at 17:43 -0500, Michael Wu wrote:

> But bcm43xx sets ethtool ops through bcm43xx_netdev_setup. Why not have r=
t2x00=20
> do the same?=20

Actually, look closer. I removed bcm43xx_netdev_setup as well as the
setup() callback for the hw as well as the bcm43xx ethtool ops which
were useless anyway.

> Then we won't have to go through all the trouble of adding=20
> things to ieee80211_hw and ieee80211_register_hw to set things in net_dev=
ice.=20
> This would work out pretty well for SET_NETDEV_DEV too.

No. We have to add these things anyway if we want them copied to the
slave netdevs. Besides, the driver has no business mucking with the
netdevs.

johannes

--=-5AXvT5UiGVQE0iZRn2hV
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUARUvPSKVg1VMiehFYAQKCAQ//Z4oPlSGd78iBnF21Da2FBs15qiLGcMt6
FBiFuZ4N2x6deO8ux9clLxMv9kdb1AvoDZz36L1gECFl4Z2k/JBRXLxXXSRQh0Fl
/Y1tdcyvHdPTnjTVGYse9hfrKT9SycZsSTp2dxts8yB1TawML7MAgQBwwqhylPMh
83fWsddtlnIo0lC+ujMHH2G4pu1J3PIHO0YtVFpI0Q/+wP8catW9daWiG49v9693
5Ea0Bln68CTXZ34TFys4ZkMGdZZ/FvPaUcuOor9n20fB3m5FeBb1gzJjOl1suoc6
BqfpGZDuaxw65CG7JZKhjWYSGOaPbdyKjOwDfJiN27zF4pyghDDwnRdGkmMP1Sce
2JPX3TBXKNaAmgk3XOTl5NsGHvOKtyU64bi2ftdhKRKuXi2NSE1EXMdHJlrdzZZ3
I/70RoW5CXgXC8gTrYwQm5wMtGM94QhqhRVK+yLVSRmWkKUAwGKqoQGgihDeL7eN
PPnJR3xf735KUIAn7kBiXIFHjpbRQznN7uEJLD1sKBx1sFxAeepY2RdBsYPFWuKm
8D4Cmzw6KuhCRX8eCnbj6902CMoU3VjNyPYEa3869bCAt5lnhVgypG/FfXmvGaIj
3N3xNIkY0oY2QR8an2LfA7oJCS2GCz5ekQ05f6dWfqJ7levjp3Kl7x0Y1UgCsN26
K7u38PudetY=
=UPH7
-----END PGP SIGNATURE-----

--=-5AXvT5UiGVQE0iZRn2hV--

