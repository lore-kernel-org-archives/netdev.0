From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH ethtool 2/5] ethtool: Add missing Advertised speeds
Date: Sun, 05 Apr 2015 02:37:44 +0100
Message-ID: <1428197864.11260.121.camel@decadent.org.uk>
References: <1422193883-30504-1-git-send-email-amirv@mellanox.com>
	 <1422193883-30504-3-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-323wEhPvsMue4ig3wOob"
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>,
	Eyal Grossman <eyalgr@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:58689 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751055AbbDEBh5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Apr 2015 21:37:57 -0400
In-Reply-To: <1422193883-30504-3-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-323wEhPvsMue4ig3wOob
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2015-01-25 at 15:51 +0200, Amir Vadai wrote:
> From: Eyal Grossman <eyalgr@mellanox.com>
>=20
> Added the following missing advertised speed modes:
> - ADVERTISED_10000baseT_Full
> - ADVERTISED_56000baseKR4_Full
> - ADVERTISED_56000baseCR4_Full
> - ADVERTISED_56000baseSR4_Full
> - ADVERTISED_56000baseLR4_Full
> - ADVERTISED_10000baseKX4_Full
>=20
> In order to reduce code duplication we added a macro to
> ALL_ADVERTISED_FLAGS in line 88 ALL_ADVERTISED_MODES,
> in addition the changed we made added speed that were
> missing from ALL_ADVERTISED_MODES
> (e.g. ADVERTISED_10000baseKX4_Full).

Well spotted.

> Added ADVERTISED_10000baseR_FEC to mode_defs.
>
> Signed-off-by: Eyal Grossman <eyalgr@mellanox.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> ---
[...]
> @@ -527,15 +516,20 @@ dump_link_caps(const char *prefix, const char *an_p=
refix, u32 mask,
>  		{ 1, ADVERTISED_1000baseT_Full,     "1000baseT/Full" },
>  		{ 0, ADVERTISED_1000baseKX_Full,    "1000baseKX/Full" },
>  		{ 0, ADVERTISED_2500baseX_Full,     "2500baseX/Full" },
> -		{ 0, ADVERTISED_10000baseT_Full,    "10000baseT/Full" },
> +		{ 1, ADVERTISED_10000baseT_Full,    "10000baseT/Full" },

Why should this be on the same line as 2500baseX/Full?

>  		{ 0, ADVERTISED_10000baseKX4_Full,  "10000baseKX4/Full" },
>  		{ 0, ADVERTISED_10000baseKR_Full,   "10000baseKR/Full" },
> +		{ 0, ADVERTISED_10000baseR_FEC,     "10000baseR/FEC" },

This is not a link mode, it's a separate capability that applies to all
10GBASE-R modes.  It's also meaningful for 40G and 100G modes despite
the way we've named the flags.  Please put it in a separate section
below the link modes.

Ben.

>  		{ 0, ADVERTISED_20000baseMLD2_Full, "20000baseMLD2/Full" },
>  		{ 0, ADVERTISED_20000baseKR2_Full,  "20000baseKR2/Full" },
>  		{ 0, ADVERTISED_40000baseKR4_Full,  "40000baseKR4/Full" },
>  		{ 0, ADVERTISED_40000baseCR4_Full,  "40000baseCR4/Full" },
>  		{ 0, ADVERTISED_40000baseSR4_Full,  "40000baseSR4/Full" },
>  		{ 0, ADVERTISED_40000baseLR4_Full,  "40000baseLR4/Full" },
> +		{ 0, ADVERTISED_56000baseKR4_Full,  "56000baseKR4/Full" },
> +		{ 0, ADVERTISED_56000baseCR4_Full,  "56000baseCR4/Full" },
> +		{ 0, ADVERTISED_56000baseSR4_Full,  "56000baseSR4/Full" },
> +		{ 0, ADVERTISED_56000baseLR4_Full,  "56000baseLR4/Full" },
>  	};
>  	int indent;
>  	int did1, new_line_pend, i;

--=20
Ben Hutchings
Quantity is no substitute for quality, but it's the only one we've got.

--=-323wEhPvsMue4ig3wOob
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVSCR7ue/yOyVhhEJAQqaVA/+KdCS3ztwPIO8aWCkRqutXm83+VglG0tD
us4+yzpShl+XJzkWEg6v3GIFRwVUqgEqxWm3PlGaLK/1O0fhePb6gbunH14tJhxk
tjf42SqDmh+hRp7kAG/hE7Fr1ofWIaQUpE6hqtyxnT3X3ons0EPQf4k/opgo8NWJ
GFBIaNypCObCV1MQvCs3b5ejWfQQL7xy71CCJPe/ysp8WMApjXoF7HI5tAgvaKjz
AatLBG7ogbrvqBVBZK9tiw5qrJFkzIwqhog0c7hpJR7ICHfFXPBjVNPW2LqeEKgq
4qEVoIALtabfzM/a4XJ8LgneHHg/yiGFI9HyDMYEFEdoIG8plyk7C084jPymMdIj
Ie0mzaTC2OohSUP7j6YweKn9z7oqY8hFgv0V6/byN6eWfZy0W+oKCZd/EabqE/FI
vjs5VsNFNK6vgkTIX4KgCUJZBZTXcd0lJvvjlmBL+LBtSouqNPLyc/TYGjkY0Min
Hfsii4LFuI8EXkE7tQys27SJqv7UU1p1n4aeO1rszEimtuo4u3oML2v4KNjRa7iN
zuOindFkoFw0ogKqiM0HY+hwCkEkTFCFrrHdwD80Eg79O8VLGxnSrjBxrVsGpRx6
szF3Hvp2mStUpcFJbubY6DEO/tXNhSPqMhMAIhQqxU1Go+RBnBbfT2nqHawJh8/6
Kh+JQF5D2c4=
=H5YL
-----END PGP SIGNATURE-----

--=-323wEhPvsMue4ig3wOob--
