From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next v2 05/10] headers, net: Define struct
 __kernel_sockaddr, replacing struct sockaddr
Date: Sun, 28 Aug 2011 17:22:39 +0100
Message-ID: <1314548559.9176.5.camel@deadeye>
References: <20110826.110820.2220935212459386472.davem@davemloft.net>
	 <20110826154248.GD24107@decadent.org.uk>
	 <20110826.120451.1765083060493659307.davem@davemloft.net>
	 <20110826.122024.278846592642798982.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-mQsVwe8vftJcwkIQ9wjp"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:38777 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751420Ab1H1QWq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Aug 2011 12:22:46 -0400
In-Reply-To: <20110826.122024.278846592642798982.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-mQsVwe8vftJcwkIQ9wjp
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2011-08-26 at 12:20 -0400, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Fri, 26 Aug 2011 12:04:51 -0400 (EDT)
>=20
> > From: Ben Hutchings <ben@decadent.org.uk>
> > Date: Fri, 26 Aug 2011 16:42:48 +0100
> >=20
> >> This #define is in the #ifdef __KERNEL__ section.  I don't want t
> >> change all the in-kernel users to say __kernel_sockaddr.  This is
> >> just the same as the preceding 'typedef __kernel_sa_family_t
> >> sa_family_t' except that you can't create struct aliases that way.
> >=20
> > Aha, I didn't catch that part.  Then this is fine, thanks for
> > explaining Ben.
>=20
> Actually, this patch breaks the build, specifically of ifenslave.c
>=20
> I'll leave the other patches in, but you'll need to respin this one.
[...]

Right, it looks like this will have to wait for a proper resolution of
the conflicts between kernel and libc types.

Ben.


--=-mQsVwe8vftJcwkIQ9wjp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATlprT+e/yOyVhhEJAQobYxAAs+ReCqZ4gqL30QujL7PZ98a9qWOHUPSQ
o8jvu0bwpSkTiYwHw2yM3ULXu4dRoD4w+SsnXYYa2jSHqdV0NukVwy5eddZvvX2T
merJ7XnE+ZpVu5haCUIXjvsjN67fL/aANBl0fyTm5/F8Tfl6yHJlvOedtDVyl+W7
sTbn2ezcLBbvcAr1k362bPuFOwuNR3Ik6DShSLwwf6UDxLZC7sK/X/pU7m0JQIRQ
KIc4wvxQG8QkojdQ98Ge+e13tlI1qH0Apla/zWCFeVNIzAwPJjFER2o6EE/D6WUn
UV7np2QCvbjoTaOOYs+oBU5ab/t0MSJa6YV8eMHhSRmz9ivc36da+tCka2R8JDUB
6HGVIn1p/iz4ZCUsSx8um42sTBy6pV5vjdW7OXhggTYUW+Vh1Q9syfNWoWeF/bH5
x+8XLGqfgTAHbhymDuXJhWQ10oq/pGCSkNL2TzxNTCO+JxpZoalM/uogTnU/RyAn
Hgsv0lELs3jAs1fn6PfidLcXFNnhChA64TqlJWaBTA8agKb43o9Hj1JYNUMEgC+z
ev7w2iCUkFnaTemvPZjnKjM/kv8A9r8DXTsMdEB6bJwK19i6C9HjKqsIUOpZR2Uj
Cr67qPeuiPW+llMw4etUZJaqaV/RTGCXqvJBjIlw4sIfs5XNbuGZxMZxvlo5+XCe
MlN0SIyccMM=
=6REy
-----END PGP SIGNATURE-----

--=-mQsVwe8vftJcwkIQ9wjp--
