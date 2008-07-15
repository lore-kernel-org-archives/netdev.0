From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: pull request: wireless-next-2.6 2008-07-14
Date: Tue, 15 Jul 2008 09:43:25 +0200
Message-ID: <1216107805.23746.14.camel@johannes.berg>
References: <20080714192302.GA2541@tuxdriver.com>
	 <20080714.204532.116542087.davem@davemloft.net>
	 (sfid-20080715_054536_698254_D32C0605)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-w3JxFrcrwePWpUBC3+AN"
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080714.204532.116542087.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> (sfid-20080715_054536_698254_D32C0605)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-w3JxFrcrwePWpUBC3+AN
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> drivers/net/wireless/rt2x00/rt2x00mac.c: In function 'rt2x00mac_conf_tx':
> drivers/net/wireless/rt2x00/rt2x00mac.c:557: warning: comparison is alway=
s true due to limited range of data type
> drivers/net/wireless/b43/main.c: In function 'b43_qos_params_upload':
> drivers/net/wireless/b43/main.c:3085: warning: comparison is always false=
 due to limited range of data type
> drivers/net/wireless/b43/main.c:3090: warning: comparison is always false=
 due to limited range of data type
> drivers/net/wireless/b43/main.c:3095: warning: comparison is always false=
 due to limited range of data type
> drivers/net/wireless/b43/main.c:3100: warning: comparison is always false=
 due to limited range of data type

Sorry, those sprung up because I made an API variable unsigned that
never was negative, I'll fix it.

johannes

--=-w3JxFrcrwePWpUBC3+AN
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJIfFUXAAoJEKVg1VMiehFY9cIP/jYK+Z1X8yjLb1cxOgw8dScB
VXLcUh3NwqPGXohxAB7W0r1xyjTxMXHg8UmFJSiIBXGyINEXnoYD1EEcuGdYB3HR
Ijf2I7a3A/gZ+gu6pnClNs68c5EtZDqi96bNfL2reZrS3Tj8zRScv7xA7szU4ZSC
IyBnRiou89u1EaI5hnUPhxfs3ceuRp4euA/ppXw28vNwiIWTL8VSJ7BRXcrQJhy+
7rV7C3qY217mV0PrK+LgXCxmdIKRCAzT3XyqwaFjDteO8oEyUqbdQLcl1IcBld8m
HwYb4GQb1lMp+gvAEHmZPjcmN7vQ175PTeWjXLT//wyKgdOXfwVvISGnTpT1A389
pTd883KzoFDEylE9wfBqsYXDGNsEIt1/57OVhTE+skcL/09AdOknGJxO6Bsvo8CB
mR/q8sq36Hm2M4zcXKceDcgZtRmYZEZKFSR0DaGvYxS7xEiYHjh3Mb/hPdizIkng
BLVPfnOO6G7lCcz/bTVvUsp1vBShWkmAUD5C83KMClc+TYa99LYxeoODpGEzcR/m
svzjIv1leEOxcI14Ay4SkqxtVGR4USNhDSq4sO7LBkc8WnG2Wm24bZ1i21jvwtqQ
tNWJCz6OhcZjuJEt2tqp52C1Lu4oqdpZIYZCuBo24zylgT6+gHcBw2KyrlELaDip
wPtsaafTPLc13NuTtIvK
=TeGQ
-----END PGP SIGNATURE-----

--=-w3JxFrcrwePWpUBC3+AN--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
