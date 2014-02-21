From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v2 net-next] ethtool: Remove inactive code snippet in
 ethtool_set_rxfh_indir
Date: Fri, 21 Feb 2014 20:19:04 +0000
Message-ID: <1393013944.15717.62.camel@deadeye.wl.decadent.org.uk>
References: <d966666f-7494-449a-a48f-728f77614738@CMEXHTCAS2.ad.emulex.com>
	 <20140219.164243.2046477353509124098.davem@davemloft.net>
	 <BF3270C86E8B1349A26C34E4EC1C44CB2C87E699@CMEXMB1.ad.emulex.com>
	 <20140221.121436.508104819618605416.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-SHK+NLWeBDV01JAO2oUe"
Cc: VenkatKumar.Duvvuru@Emulex.Com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:54914 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752456AbaBUUTO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 15:19:14 -0500
In-Reply-To: <20140221.121436.508104819618605416.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-SHK+NLWeBDV01JAO2oUe
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-02-21 at 12:14 -0500, David Miller wrote:
> From: Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>
> Date: Fri, 21 Feb 2014 10:28:24 +0000
>=20
> > There is no option for --set-rxfh-indir to reset the indirection table.
>=20
> But this can be easily added to ethtool.
>=20
> My point is that the intention is _clearly_ there to provide this
> facility.

This is indeed intentional, and was added by:

commit 278bc4296bd64ffd1d3913b487dc8a520e423a7a
Author: Ben Hutchings <bhutchings@solarflare.com>
Date:   Thu Dec 15 13:56:49 2011 +0000

    ethtool: Define and apply a default policy for RX flow hash indirection

I can't remember whether I wrote a patch for ethtool to use this feature
but I must have tested it somehow...  The ethtool command isn't the only
user of the ethtool API, in any case.

Ben.

--=20
Ben Hutchings
A free society is one where it is safe to be unpopular. - Adlai Stevenson

--=-SHK+NLWeBDV01JAO2oUe
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUwe0uOe/yOyVhhEJAQr6VQ//VFQbkkpCxCpGzWlrBv+Wt2+3NKCQ/lE2
SgwKXT/uIUQVAY0lr9NxVc1A7dh2Q8242qVB86ChjL93J4MQXbDccQ/Wj+D8AQJl
jDdTa4PkF3Tq76wbU5TmdVvO4RNssXNYhGQZ8dQVS02/l0s6L9TpWbO8Veh8wbSJ
t4ZLdCF+lmibQdKIVt+rtrLGWgXK+N+73CX9HHZY3g3wQr//iycABytgqgEnTEu4
Yf/P3imLX5+IHGkmxjLAJtswByvnoH29kMnoSO4pJoYEOvr3PIYsZH1OebhLcbhY
VNgqWzzh9jAM5OJPMVuOpjOB4Ee/X9rQ1ebwEcdQfdYvZiX8eOAIQnMGLdM2Oq1W
YIssPMNwm/glEPK+SWKgYhc9UH3YpwfWQajifDhYlVJUdzZPKPIBfleq701vR9uc
TNBXfVE+yKoGQtSxGAlwvwJDwFM7PkCOz13s+1oVUrRJousP/g6ZtHiBZ2iyWoak
NJpfTIgAsfJBLoCKJRVv9wmytVrhj2txtLVzSlaNJGztvU0U1jECD7pPTCv13nR+
zpZiQ7/pDfXiaL4tJ+rYnhZ4SuVVYaR2XmyTFcaqmuQbYpRsElwHpa0vXDeJKtiU
vg+39z+bH80A5WQllV/8nl/qmkGjW6A0iEq21zDUlKq8XspfYL7Y02mMg8OxpLOm
nRUxoHZGydk=
=AWvw
-----END PGP SIGNATURE-----

--=-SHK+NLWeBDV01JAO2oUe--
