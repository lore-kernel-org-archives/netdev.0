From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: query: Can ethtool be used to print Expansion ROM version of
 the adapter?
Date: Wed, 28 Jan 2015 03:52:41 +0000
Message-ID: <1422417161.2709.10.camel@decadent.org.uk>
References: <26E3F92EC670BD429DB5CB319D773C13C7FE19@nice.asicdesigners.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-1rr57nzq68jtWyv+ztjq"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Nirranjan Kirubaharan <nirranjan@chelsio.com>,
	Casey Leedom <leedom@chelsio.com>,
	Kumar A S <kumaras@chelsio.com>
To: Hariprasad S <hariprasad@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:37954 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751484AbbA1Dwx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 22:52:53 -0500
In-Reply-To: <26E3F92EC670BD429DB5CB319D773C13C7FE19@nice.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-1rr57nzq68jtWyv+ztjq
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-01-28 at 02:18 +0000, Hariprasad S wrote:
> Hi,
>=20
> For printing the Expansion ROM version of the adapter, we were thinking i=
f ethtool
> could be used for it ?
> There are fields in ethtool_drvinfo to display fw_version and driver_vers=
ion. Also,
> there are two reserved fields present. Are these two reserved fields alre=
ady in use ?
> Could anyone of the reserved field be used to print the custom adapter in=
fo like
> Expansion ROM version ?

Yes, I think reserved1 could be used for this.  But you should rename it
in the header and update the comment to indicate what it's now being
used for.

Ben.

--=20
Ben Hutchings
Teamwork is essential - it allows you to blame someone else.

--=-1rr57nzq68jtWyv+ztjq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVMhdDue/yOyVhhEJAQok4hAAnQPPoAbM71Zpbr4HhEcocvG2w01M71eO
Hg1TGpJMEFQDN8DkBY4rfH8ohBBgEuZcbOhbjACGyXKZNn6EEU6sNQoiaJjOCYnI
DBlJL+GBR927F9a1G4AodDtgAIREY0WPENmMJf3UGwNPQ5u2sf0Twek/hupcj4DE
cBvqgqs5YXJNMWzyEhuU1hmuo7xJk/HOA419yWdhDv9PyMiCcj1aFwPRA7yULITs
jQSPLffjza9g5e/uwUOzrR0yTm8nr6gVM8IBUsj1dvFh3IhZAxpvccYJ7UHPMk2e
oL+9H53ccxbTVCnyVjG75rgNhORahgvUjNLvq0IY256IToBq57Gey9P6qvtr5ZVc
VmPmAAsCRLY8jZkGmeug9plOrtiOzcR2LKIHfVAn5XgIpJPOlers/sdQ7Lnov+VU
n+7kJcJ1JPw3WOGgEv+i7XG1GUf1SiFx67lAFamWugaQl1FwFF8cbLIb+GEkTPIG
Q2lpTkU7qZuHJsPw+fHXF8HQQdQwocKx8aQviTn1MAnm4WJDYKx6aSpJhTtaBxxx
1IQjILCcSSRk3KxYdmNJCugxaOb2Sqb0bFwUWHNni8+HOe9zaAVK/Ywqf9oXBvVi
6wXmsLbq0mRlVVKAQFwXh7bEp0EeZPNx4iR0tXRAe/EMvTFDBJAvI2eDjh2It2Ea
oIQf5R6MI04=
=XQIM
-----END PGP SIGNATURE-----

--=-1rr57nzq68jtWyv+ztjq--
