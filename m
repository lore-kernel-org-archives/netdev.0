From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH 1/3] drivers/staging/rtl8187se: Don't pass huge struct
 by value
Date: Sat, 13 Aug 2011 18:05:31 +1000
Message-ID: <20110813180531.34a47d9bf4851f8c1e9a227c@canb.auug.org.au>
References: <alpine.LNX.2.00.1108130054220.7387@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Sat__13_Aug_2011_18_05_31_+1000_R9hXPCC5XbGmN6x8"
Cc: Greg Kroah-Hartman <gregkh@suse.de>, devel@driverdev.osuosl.org,
	linux-kernel@vger.kernel.org,
	Andrea Merello <andreamrl@tiscali.it>,
	Andre Nogueira <andre.neo.net@gmail.com>,
	Lucas De Marchi <lucas.demarchi@profusion.mobi>,
	"David S. Miller" <davem@davemloft.net>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Stefan Weil <weil@mail.berlios.de>,
	Ilia Mirkin <imirkin@alum.mit.edu>, netdev@vger.kernel.org
To: Jesper Juhl <jj@chaosbits.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:48613 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750907Ab1HMIFw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Aug 2011 04:05:52 -0400
In-Reply-To: <alpine.LNX.2.00.1108130054220.7387@swampdragon.chaosbits.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Sat__13_Aug_2011_18_05_31_+1000_R9hXPCC5XbGmN6x8
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

On Sat, 13 Aug 2011 01:04:36 +0200 (CEST) Jesper Juhl <jj@chaosbits.net> wr=
ote:
>
> From: Jesper Juhl <jj@chaosbits.net>
> Date: Sat, 13 Aug 2011 00:51:40 +0200
>=20
> struct ieee80211_network is fairly large (more than half a kilobyte),
> so let's pass a pointer instead of passing the entire structure by
> value when ieee80211_is_54g() and ieee80211_is_shortslot() need to
> look at a few members.
> Also remove parentheses around the values being returned from those
> two functions - 'return' is not a function.

Also, is there some reason that they are not "static inline bool"
functions defined directlt in ieee80211.h?

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Sat__13_Aug_2011_18_05_31_+1000_R9hXPCC5XbGmN6x8
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJORjBLAAoJEDMEi1NhKgbsxHsH/2T6oRInmC3zpyPeRLSebI/X
l2GvmTcgxhdTNWFXv/IDIlO+rXn7rjVRRK29uTtKYw6iF75ZWgzu3Fk3/P57VtFG
r+bj/IUScZKyDVYcRJtWms3dmwd/nn0gScLtA5SftBLEeG491TYCA8j8ldOd21iC
Up31bhPu/keECV2ZzkuVY+vsTZAt+QBw/CIIpJcIjGa6lcIADkwbelLAW7Q6RPX+
1Vqzd+VMc1tojP7BSna5NTMmk73AsnpQlUPh+AfFZ+xQaW9dtt5EGZ7AcKSvMHMH
IaFyLL6oA28PlmcJUeXcC1BJ8DqXo1GPXFFrhzZVs/YO6mcKPk5YD9+0QDST3ro=
=C2Qq
-----END PGP SIGNATURE-----

--Signature=_Sat__13_Aug_2011_18_05_31_+1000_R9hXPCC5XbGmN6x8--
