From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] i40e: using for_each_set_bit to simplify the code
Date: Mon, 23 Sep 2013 14:10:21 -0700
Message-ID: <1379970621.1906.2.camel@jtkirshe-mobl.jf.intel.com>
References: <CAPgLHd8MsmVDONTENFNcRNf=7xWPGE5LJD7Z+0oNS5Lkscr4Xg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-4TetKKCtPKr2xp9cC+za"
Cc: jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	gregory.v.rose@intel.com, peter.p.waskiewicz.jr@intel.com,
	alexander.h.duyck@intel.com, john.ronciak@intel.com,
	tushar.n.dave@intel.com, shannon.nelson@intel.com,
	mitch.a.williams@intel.com, yongjun_wei@trendmicro.com.cn,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:15910 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753938Ab3IWVK3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Sep 2013 17:10:29 -0400
In-Reply-To: <CAPgLHd8MsmVDONTENFNcRNf=7xWPGE5LJD7Z+0oNS5Lkscr4Xg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-4TetKKCtPKr2xp9cC+za
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2013-09-23 at 11:39 +0800, Wei Yongjun wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>=20
> Using for_each_set_bit() to simplify the code.
>=20
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 64
> ++++------------------
>  1 file changed, 12 insertions(+), 52 deletions(-)

Thanks! I have added the patch to my queue.

--=-4TetKKCtPKr2xp9cC+za
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAABCgAGBQJSQK49AAoJEOVv75VaS+3Oe6oP/18+Js9Y5bAHIQpGi5vY4fF7
cHuRjjn8NXHRJiAJYrlvwhBHaoXjDgNgVl7AoLelL++tgPam2HrkQ59chLwltoHn
C63Fu6RoRyZ0A7Ke0XZ6I8NWiBPOdhgXMRzwWmUhyegfCJPsJSMwFLOnmXD1iIEo
1GYMrhkNa+znNKW7e1YHlLDJaqev/WDpEC20ZgT5Ez3s+BopsqEsR8tHYuoKr069
mQZvrnxUpPJ0upo+lLx9Zp1a/7g5LYzCmglirfkzz4I3CNwHC6RU1he2p26bibBl
USBob6Js6yTjdtOnnvC+4m/1b7/VYhkWn3r6BlScC9zUGuluDKEDAyaHMFdqjvUQ
yPbveSH0tUJ2mcKFbG+F7HeKa6wNxC94qJGeg8rmLiBtIshKBK0UML/ZgOyD1jdG
2WK0xtBJRnBU1rGzJPVaDhASwg9Sh4DfkwVr+AS6lUQ1awJPfeo4vXzyzrpiUzJD
g7Y/i96RE3Ldl/OwjYem0nuMLedr90BkIvOEoKw+m36dK0RHpIcTPmAtdKDddm9V
zBvCZY1ObgUWskbd6MV/WLrEOiQYtrq7gooeTT6/zad/tOjAjgrgJMaHNVJeIVmX
9adZbLYJX/d27A5alCWXfLiwLRh5DwdIuWHb84vNKTKt3o+p8V9e3uuBbl5yGCK/
PGhpRMDN3oTVbraJY5gX
=QOsY
-----END PGP SIGNATURE-----

--=-4TetKKCtPKr2xp9cC+za--
