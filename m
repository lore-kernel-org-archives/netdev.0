From: Mark Brown <broonie@kernel.org>
Subject: Re: next-20170608 build: 1 failures 4 warnings (next-20170608)
Date: Thu, 8 Jun 2017 11:32:31 +0100
Message-ID: <20170608103231.gmqx6qluzcjwzrst@sirena.org.uk>
References: <E1dIuCM-0000cQ-QM@optimist>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="oo7lue4fim4mgc5h"
Cc: kernel-build-reports@lists.linaro.org,
        linaro-kernel@lists.linaro.org, linux-next@vger.kernel.org,
        netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Sebastian Reichel <sre@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mezzanine.sirena.org.uk ([106.187.55.193]:53950 "EHLO
        mezzanine.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750725AbdFHKcm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 06:32:42 -0400
Content-Disposition: inline
In-Reply-To: <E1dIuCM-0000cQ-QM@optimist>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--oo7lue4fim4mgc5h
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Jun 08, 2017 at 10:57:50AM +0100, Build bot for Mark Brown wrote:

Today's -next fails to build an ARM allmodconfig due to:

> 	arm-allmodconfig
> ../drivers/hsi/clients/ssi_protocol.c:1069:5: error: 'struct net_device' has no member named 'destructor'

due to cf124db566e6 (net: Fix inconsistent teardown and release of
private netdev state.) which missed this instance, presumably due to a
combination of it not being in one of the normal networking driver
directories and only being buildable on ARM.

--oo7lue4fim4mgc5h
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEreZoqmdXGLWf4p/qJNaLcl1Uh9AFAlk5J74ACgkQJNaLcl1U
h9CXgAf+I6yj0qzQFDYMCaWbNd5DY77250VPlirMUQLQgibmTec5y+YMYQCh1+TN
fhJPtGuGC1QwNKG3CkpxSBooRG7oKmWng0vtHyNUPgG+5eP4OjU45349sUNXL/EH
jlfSRxOXhZeMk6KbrZuKu/KJKfnhhZ1I5WiZKQAQ7ZyEP2XhaT0c9Riv1CZWelGa
UlrB3S9ZxvQteekIOaA5GLiftJkeq3R4la0Ha5F1NfWl9D5MbhVZLa87LAHKKUtC
Gc4SV5S9ijgsEdwORKI2SquMWH2Tx/7D9yfB3xUSiR8EUPH4zOXhuU6SMtCPMWAl
vKLuXRd60oFhS/ITnruv0GnyiNASdg==
=VbXP
-----END PGP SIGNATURE-----

--oo7lue4fim4mgc5h--
