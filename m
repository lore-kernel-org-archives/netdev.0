From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] ixgbe: convert to use simple_open()
Date: Wed, 17 Oct 2012 15:31:44 -0700
Message-ID: <1350513104.2139.20.camel@jtkirshe-mobl>
References: <CAPgLHd9sFav1MKPCdHNjXM37ZEitiJJYFkH_Kv-8LsSr2t4TYA@mail.gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-XJf76FoUqddvh88wk0wx"
Cc: jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	gregory.v.rose@intel.com, peter.p.waskiewicz.jr@intel.com,
	alexander.h.duyck@intel.com, john.ronciak@intel.com,
	yongjun_wei@trendmicro.com.cn, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:27359 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751980Ab2JQWbq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2012 18:31:46 -0400
In-Reply-To: <CAPgLHd9sFav1MKPCdHNjXM37ZEitiJJYFkH_Kv-8LsSr2t4TYA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-XJf76FoUqddvh88wk0wx
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2012-10-17 at 16:26 +0800, Wei Yongjun wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>=20
> This removes an open coded simple_open() function and
> replaces file operations references to the function
> with simple_open() instead.
>=20
> dpatch engine is used to auto generate this patch.
> (https://github.com/weiyj/dpatch)
>=20
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c | 32
> ++----------------------
>  1 file changed, 2 insertions(+), 30 deletions(-)=20

Thanks, I will add the patch to my queue.

--=-XJf76FoUqddvh88wk0wx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQfzHQAAoJEOVv75VaS+3Og1sQAI02I99OETXjLS4CA9frESZy
mlcv6gMpTCIBTlNIlqM13YBrAJfLwVEuFyq8Iv2pv9Ko5O45AUbFzRqDNwEJedIF
ymNoemIRlVGkE7jOofnkUm9WwaXW+fFl/Zt37+A1n1YFWkaOzsda+h2TzFeHI9A5
fycmht1D0Am2NzwqzBXP0p17b773K9DRhu1YF0/tX7c+jQhuFZ2C6Aw5o8nazMH7
LGl5Isg7j+5Gj2ssrKZ1/Z4DW0+dZXVYz8mRXZl3fPshRWfSveEl5zcqNhuBEQgp
srby0wPjYzHZA5hsSqlR3UwS352nYNRD4xNbusTRP+Co+D2naKF2THq8WYTS2ZW7
DGSjqueD4qEqQJ5AvoYQb0OWNVe5qZM+xgbRdEKTMyYn6PD9zwuVrB4K1qCt8S4Q
uhVOijgGU78Z2ai+hysAPlqmTmruau/tLwTraPzJo/7avuhh2CJwFvTgQJCmB0zw
jP+DPN8zugT6oUFFeCLo/2CmYm03CDlDhoTBWPBXfof10KXoMnjGOu8LyNjNt2Jv
vNLKRkcpCOLdRTC/hiGiOiNvi353C3ry13LUl6C3nMjDHrajYyCJy/KrsAY9/JL9
zSRtLdr7zrgtqZulbjPc0Bn/6yUvycyLyiCF+PB8euF3+QzERSxUt9Sk8EWbA0VL
9thXdaUnwng1qKVhJ7l3
=WGEa
-----END PGP SIGNATURE-----

--=-XJf76FoUqddvh88wk0wx--
