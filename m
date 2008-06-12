From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] Do not activate promiscuous mode on wlan interfaces for
	bridging.
Date: Thu, 12 Jun 2008 20:59:04 +0200
Message-ID: <1213297144.3730.35.camel@johannes.berg>
References: <1213232760.6645.24.camel@localhost>
	 (sfid-20080612_030607_332834_1EFDE126)  <1213255570.3871.8.camel@johannes.berg>
	 <1213294793.6615.16.camel@localhost>
	 (sfid-20080612_202000_504292_98E93460)  <1213294852.3730.31.camel@johannes.berg>
	 <1213295643.6615.20.camel@localhost>
	 (sfid-20080612_203408_119945_EA437275)  <1213296250.3730.33.camel@johannes.berg>
	 <1213296815.6615.24.camel@localhost> (sfid-20080612_205338_785787_5D25D535)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-j0naZQyRNEZmr0GOtJqA"
Cc: linux-wireless@vger.kernel.org, shemminger@linux-foundation.org,
	j@w1.fi, bridge@linux-foundation.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Luis Carlos Cobo <luisca@cozybit.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:57078 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754082AbYFLTAG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2008 15:00:06 -0400
In-Reply-To: <1213296815.6615.24.camel@localhost> (sfid-20080612_205338_785787_5D25D535)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-j0naZQyRNEZmr0GOtJqA
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2008-06-12 at 11:53 -0700, Luis Carlos Cobo wrote:
> On Thu, 2008-06-12 at 20:44 +0200, Johannes Berg wrote:
> > But in response to what mac80211 command are you sending the promisc
> > mode to the hw?
>=20
> In the function associated to .configure_filter (struct ieee80211_ops)
> in the driver, when (*new_flags & (FIF_PROMISC_IN_BSS))

But it is a "real promisc" mode not restricted to the BSS? Maybe the
solution is to just not promote promisc-in-bss to real-promisc when AP
mode is active.

johannes

--=-j0naZQyRNEZmr0GOtJqA
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJIUXH0AAoJEKVg1VMiehFY7CUQALoOvnpurdlVDrszBWzzQasd
ftp4ubEMXcIz5L+N+tA2HMXzPiTx3P1eYrxESB0mF91sQcb3OGUex82Uj8nUZAuU
tcxHZ8tQ6lU2/U69wcoFSezjGamiqQRJbEUYUXA3cpccWsNrGLsCz7t2CobzOGWz
Z7Qc7CeRhsPKpkNenQcC+i1qGUe3HJtsrNXsysWU6v/+rYcHaKKC3CgUZ6DNb4Fq
3Rp4X3hur1kG4ui7o0wMsIPSjAsr7gf7fYaLJYrkO72RjD5b7dzAJuiAawaZI+9R
t2/bGxePVwuNjIRsIQDf3QHEfap7NioWKXgpS/xITqcIFNaVoDxgHachZnQT+0BH
H2Q3sOy2CZzlXWSa+e2FsBs+/WoCNyYBeOEo9f/RdO02XdYWI3uGKMfUBk7fhm10
e6KwFmkH0+Yr7JJlfoZPmBEIRIBCZHlBc18MIifQKuK2HIpy1Pu+3HpAtmWf0iHk
4F6+sA1pZr/jr9XhMd4KB4rMjVUeoMNgHuPE+XQspv6VA8+1SIz4FvVHm0XDnOT7
J1jqlXEOP8FsOw7rG7FUw4Wx63gj6hKb2l8LRupKVhD0JKIhoaTlkEQlK4ZT3Vj2
xxhrYJPN55w2jHe6YMT+pG+tO/GZNZ2CRa5e/PZHlEZd4yD3L3cpf2GA7H26MGM5
J1E/gm5TT3gQcb+WCMLz
=4mCi
-----END PGP SIGNATURE-----

--=-j0naZQyRNEZmr0GOtJqA--

