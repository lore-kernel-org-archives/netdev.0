From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] ieee80211_if_set_type: make check for master dev more
	explicit
Date: Thu, 04 Oct 2007 20:44:48 +0200
Message-ID: <1191523488.7367.16.camel@johannes.berg>
References: <20071004113343.552139D502B@zog.reactivated.net>
	 <20071004180900.GG6037@tuxdriver.com>
	 (sfid-20071004_193833_064202_C9F1C827)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-/u7Wgpxry+VC3Sz0LKq/"
Cc: Daniel Drake <dsd@gentoo.org>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:59440 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755820AbXJDSoj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2007 14:44:39 -0400
In-Reply-To: <20071004180900.GG6037@tuxdriver.com> (sfid-20071004_193833_064202_C9F1C827)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-/u7Wgpxry+VC3Sz0LKq/
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2007-10-04 at 14:09 -0400, John W. Linville wrote:

> --- a/net/mac80211/ieee80211_iface.c
> +++ b/net/mac80211/ieee80211_iface.c
> @@ -106,7 +106,7 @@ void ieee80211_if_set_type(struct net_device *dev, in=
t type)
>  	 * which already has a hard_start_xmit routine assigned
>  	 * which must not be changed.
>  	 */
> -	if (!dev->hard_start_xmit)
> +	if (dev->type !=3D ARPHRD_IEEE80211)
>  		dev->hard_start_xmit =3D ieee80211_subif_start_xmit;

That should work as well although I think you should update the comment
above :)

johannes

--=-/u7Wgpxry+VC3Sz0LKq/
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUARwU0n6Vg1VMiehFYAQK6jg/8C4JpPKFTXd2Sf1VRnqEHj+vwqLp/v5Td
/yXYwqcSgHY2G5YvSvFBeVjfkKn42i+9fmoxilViouQdKAVaXWIVPF9nGOkMfuHS
7x3WlRB7COvgiCxMEQl49w0rmhBomIoaT3k8wnLyI37H0RpG3ToVjBs34DXD0lyT
V89r8ovTQQKoiKKuLh4Npussg1uuxJ7NUMz+tU1eqTdhj2kdJsPdDNEhC3+7OLIc
TjqXMVMcDrvWG2Fm6ExAloq0FrzCexTyS5UIBQLFm7dTGwjasH+Uz8vJ55BZ0vdC
CWnTah18RCoyytBy2lNc7JvKA8sPH+j6FMgAC+tC5wZpSNVvIRwEwzS7JIcqVb62
d76gQIfKGBDLa+MrlZzoeu97n1XAlTorZ9Lp7Ou49C+q+BWEGyfHIe1FG3c8vi9d
9eO9tdKmEW63w9VNuifR81uU5cjRRoGaAllnfVG6pnL0UVkTH3bMcvavEmzFhavH
bqo6GsfiLJZLrAaJuLObJpzundeO0C/vwdKIAb31mqCCT9v6rXvSLMmT7zKb0vZ9
YCNBu5rwNeL8NG33l1tiXC5NqWWh5J6CvvWdGGNDgwm4mmJJHS/qYOEB3msjG5+s
RpQbTZa+OLPt0COhU91VCiIv2/7HLFMdv7kq5AzClLNqZNZMUpEu9pvXORU1LUip
MU3LMugqJZE=
=RM6L
-----END PGP SIGNATURE-----

--=-/u7Wgpxry+VC3Sz0LKq/--

