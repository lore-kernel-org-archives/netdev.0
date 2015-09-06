From: Corinna Vinschen <vinschen@redhat.com>
Subject: Re: [PATCH net 1/3] r8169: decouple the counters data and the device
 private area.
Date: Sun, 6 Sep 2015 12:38:55 +0200
Message-ID: <20150906103855.GG30539@calimero.vinschen.de>
References: <cover.1441454454.git.romieu@fr.zoreil.com>
 <cc3b19f13a82e27928eb8cb3ee0d831d7fea62f8.1441454454.git.romieu@fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="H4SyuGOnfnj3aJqJ"
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	pomidorabelisima@gmail.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:47208 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750995AbbIFKi5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Sep 2015 06:38:57 -0400
Content-Disposition: inline
In-Reply-To: <cc3b19f13a82e27928eb8cb3ee0d831d7fea62f8.1441454454.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--H4SyuGOnfnj3aJqJ
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

On Sep  5 14:18, romieu@fr.zoreil.com wrote:
> From: Francois Romieu <romieu@fr.zoreil.com>
> @@ -2335,24 +2337,25 @@ static void rtl8169_get_ethtool_stats(struct net_device *dev,
>  				      struct ethtool_stats *stats, u64 *data)
>  {
>  	struct rtl8169_private *tp = netdev_priv(dev);
> +	struct rtl8169_counters *c = tp->counters;

Minor style nit: Shouldn't that local var ideally be called "counters"
as you did in the other functions?


Corinna

--H4SyuGOnfnj3aJqJ
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJV7Be/AAoJEPU2Bp2uRE+gkuUP/22BLHv6G/9lTldDuSCuBDsy
eU34kNLZHXS3qJxOesIkYhoDUiJ7y6+shKy57PDqb7MsbQH70ToXQr9W0DrWTdOd
YxwXoq/6HL61GQ8Ya6A9JPuVYCAU5f+FGNyLykKr4MzM9YPcWIzqX9ge1BU4/F8N
2bsZ6QM7M5o73RmpV2YI8YCAR7ncuUxUHcGI5QJohuofK+Do1xJmnqw9diXkYkAe
DW88OT8maXIWxael7Oa7/yUU7HJJk9cq/nBD7IO/nlvsqTpSRcsU4QFZo4IezGoa
bxd8imHQaapQRBYE9OVO9mLe38Wdd1NQwQfSt6/QVvak5EvXOGLrU0YMeLn98pNT
NkhrWaWdES2BixFSxFFxDW9MCTOA6fWtZtGrZYNfQlfhZdkJTandzPEFQjCJt/C3
pxeCR/R+wVDu8ShyIqVuldmjfALf8lIO4Y8p7uavriyZpGkZQ9zIU8Uyo5KZSjjw
wANoTUUDtYwnCProM4ipEVZrQ9xnDXh/venBH5NJpErP52MFdpmTljcQkH5b56LG
3NfPSv+iWIUVV+gwYTq1Vw0O9B5RxsscMgDy/D0x1MgjvGC6Xq+iZVmNxUcRbGlS
l1zm4r//xapOAb1ZMPh4OB70O/CgTtgHGCrMlPzRol0thB/ipv7Vjs9pMj2U/3cP
WjJkZErNyuZJW/zwq0Ry
=Pah1
-----END PGP SIGNATURE-----

--H4SyuGOnfnj3aJqJ--
