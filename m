From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next v2] igb: reset PHY after recovering from PHY
 power down
Date: Wed, 21 Dec 2011 22:46:04 -0800
Message-ID: <1324536364.2327.39.camel@jtkirshe-mobl>
References: <4EEE9248.8020009@jp.fujitsu.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-IyvKCn2a0p77AT83t4Ip"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:8416 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751646Ab1LVGqG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Dec 2011 01:46:06 -0500
In-Reply-To: <4EEE9248.8020009@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-IyvKCn2a0p77AT83t4Ip
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2011-12-18 at 17:24 -0800, Koki Sanagi wrote:
> According to 82576_Datasheet.pdf, PHY setting is lost after PHY power
> down.
> So resetting PHY is needed when recovering from PHY power down to set
> a default
> setting to PHY register.
> Owing to this lack, NIC doesn't link up in some rare situation.
>=20
> Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>=20

I have added this patch to my queue.  Thanks Koki!

--=-IyvKCn2a0p77AT83t4Ip
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJO8tIsAAoJEOVv75VaS+3Ox24P/isgCR/vPd8D+h9+YxESvm86
EfnGUpXMrG0J9gNQrwmhAenPuVKQvrAH60VuWdxOPwDq2Bi6XAVNHeE7ThNl33RL
22larXNmu7byL5YxIQl8DVvOj8iX/7KhvhoXI3gKQYqwsPxFk/Stgc9M2v4seJoq
gfZQp1pDNPhDhvIOeVlTv3FmBWOr26k+xofrEIGh2YSjthMoM7XB0Y5f0MPT3Xgx
4apIKJ16TMwHswTOQ8Nftyhf2q6eRgoMxVrtVyUcYoG3gtj0XsBXIrrRQcxOcXYJ
IWa0PVfzwTUrrGi+Pn+K/ZOWalfORd4tg8p2UygqmjZZFBYfyNKxMQEGAbzMsHxm
QWpma28Y5xMkA0Bjakc0O9E+fDZDQ9tWf/ZX5oFbkUvKquibYMRt1IiMY2bp9b0z
onL0afa3u/UnQODvFlvKBB0ALUdTQa84/WwNBcbELKHlTGgaWzFm28zhjOMzRPsS
heIFqqNIXP4QnNZdyDf/g/d8JGIxBa7Hut35BMdeTtiBiXg+6hOENKXMQniYnxMY
h6P7EnUBvW8yGx9aHBlE8Ec4fCey3ki9QrQeAcYauh15EjUiWF8/t2sP0yn7eRPa
0qwmMsRP0UzO5W/DN3JZdT9PmRguzD72qo4wuDbbtjw4xHhOlPz61SoGKgoGJBDu
KOGfds5AwLKoQR0g5aCc
=/MlH
-----END PGP SIGNATURE-----

--=-IyvKCn2a0p77AT83t4Ip--
