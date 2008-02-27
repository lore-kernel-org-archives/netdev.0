From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [NET]: Messed multicast lists after dev_mc_sync/unsync
Date: Wed, 27 Feb 2008 12:37:15 +0100
Message-ID: <1204112235.3729.54.camel@johannes.berg>
References: <47BAEE3B.7020502@trash.net>
	 (sfid-20080219_145720_362430_7BA05F2C)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-+jTO7Sxzdpbq11TGAZqc"
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:55174 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751856AbYB0LhX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2008 06:37:23 -0500
In-Reply-To: <47BAEE3B.7020502@trash.net> (sfid-20080219_145720_362430_7BA05F2C)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-+jTO7Sxzdpbq11TGAZqc
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

   =20
>     Commit a0a400d79e3dd7843e7e81baa3ef2957bdc292d0 from you
>     introduced a new field "da_synced" to struct dev_addr_list that is
>     not properly initialized to 0. So when any of the current users (8021=
q,
>     macvlan, mac80211) calls dev_mc_sync/unsync they mess the address
>     list for both devices.
> =20
> -	da =3D kmalloc(sizeof(*da), GFP_ATOMIC);
> +	da =3D kzalloc(sizeof(*da), GFP_ATOMIC);

Could this be the reason for us seeing "multicast address leakage"
warnings?

johannes

--=-+jTO7Sxzdpbq11TGAZqc
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR8VLaqVg1VMiehFYAQIUCg/+OUnVMYq9hw4iZ/iwOWQHKLCOA0HmGCyq
cvHBm83vWwwswI5ysbXrCiuifcVIGYJw7XZCQHtXcdaUdjaSAUmFyC8a0qEJaCux
O9x/rx9iXKmzfFf68Bli0EAhVdlWxIRPcw7doTbHLTvpo+OxJ2sRGakQ0TRG+qYY
i7fO8Q85YSjbatHDycpR+uWb5CoZFAvaYl2iZr+YLh0zXXbowlTCu8w9uExPVcwP
07dNWJSuzU07NC+OsVWLefWsQSOnoXndnM7pg2GhwlUJ+o+HLWVF4AqImSOJ0KEA
djAvvBk2aQGHpbbQj5ueEBzCT0EVOfkayHXrgiz2WtwUn5JK0sKDBsAflqxeXYcb
2cMNpaTqfj0p6XjQHIXDTaH2lnzuS0igu9j/wnIWGqa7ZksGIdVa2ZALmnBws8RN
wMFoM+reUTdOXmXmiok4tIAhSci0adaGmmMybTaNXweWtvohYgfA48L6L3dxK53J
EtZpRRt8MgXv77v535UEly6EB1sJesZTFsMlLsVXzpo0q8vduQVyRd+iRXfWGokv
hgR+36RbA2NBENnGSBjqJcRo5xKXsPQZXHw4VP7xc2xGBXoBDkr5setxxji6f7Rd
YiaQ0YO1TNuC9MR3L65U9xC6WfZHyLwaCBNmkCmIQKBq3mCxqDvIbguWi3M/Xdrc
yIulVbUwAUA=
=9ykE
-----END PGP SIGNATURE-----

--=-+jTO7Sxzdpbq11TGAZqc--

