From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next] ethtool: Set cmd field in
 ETHTOOL_GLINKSETTINGS response to wrong nwords
Date: Wed, 16 Mar 2016 23:36:32 +0000
Message-ID: <1458171392.31907.39.camel@decadent.org.uk>
References: <20160314010537.GD21187@decadent.org.uk>
	 <20160316.192638.370528273688631022.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-u3xAeliFe8Azhya5GKU1"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:55268 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752339AbcCPXgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 19:36:36 -0400
In-Reply-To: <20160316.192638.370528273688631022.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-u3xAeliFe8Azhya5GKU1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-03-16 at 19:26 -0400, David Miller wrote:
> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Mon, 14 Mar 2016 01:05:38 +0000
>=20
> > When the ETHTOOL_GLINKSETTINGS implementation finds that userland is
> > using the wrong number of words of link mode bitmaps (or is trying to
> > find out the right numbers) it sets the cmd field to 0 in the response
> > structure.
> >=C2=A0
> > This is inconsistent with the implementation of every other ethtool
> > command, so let's remove that inconsistency before it gets into a
> > stable release.
> >=C2=A0
> > Fixes: 3f1ac7a700d03 ("net: ethtool: add new ETHTOOL_xLINKSETTINGS API"=
)
> > Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
>=20
> Applied and queued up for -stable, thanks Ben.

This doesn't need fixing in any stable release.

Ben.

--=20
Ben Hutchings
If you seem to know what you are doing, you'll be given more to do.
--=-u3xAeliFe8Azhya5GKU1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJW6e4AAAoJEOe/yOyVhhEJGz8P/RZoqJ3KNbxdpgOKRV9A5TdA
h5hF+ETq/sibuAFwI2bSxoLAkrMtm0JA4sLUP8yLd+Yco4QH+22fL+2VfkhDNq0C
zXdcTbKVX+JIWxAPCDhtiNwFAcsdb+whTs/oV5DGAzZ5YY0+a6AwOi4Bpa+DzO9X
8X4CgTNiCaNE18DFQBFmpAhdBESDk6+V9zN4H9wwP3B+jug9TckvAzHM4RU4q7KP
peNRXp/EmIB0d+2iFfS/Qicp2ymjOVl69EOe7FaRyrLaDbseitsai4Yc9B4t3z/E
LsaJ62ZeYezo6gLx+mat82LDP/rxRWJ2Ul771NQDB3fycc7nA0tp8gh+3QDRTHus
vQiXry6FJTxu7HilQIfn3gambcqsbeVMhJRncbyUE76gfBjqLsVl0kf1SwZLTka3
RjibaVtmIJ0WMVmPWX9sXf+6IbuqzcZKinQVyDgx2VpTgWg/tFtMZK8tDWDpi+pU
PAwxNuCq+k4vMgw+OsDIg7nwRa4GpQ+6mcPNU0UjAjsQGAEGmL/AnLwvR0Zy7pw8
UN5e/6Mb2HIXvIndBjX0gvxZjRzmLs09kxHdmc06wo07x00GM3tu+DEpQyw1VLl/
oOXtntPp8pFHJKvR5Bgg1dUEknbJljnYFyzoG235w4XAoIh+k1xBttClAa2Bq7B3
YeMrUfASniGi4+bE+o7Y
=stjF
-----END PGP SIGNATURE-----

--=-u3xAeliFe8Azhya5GKU1--
