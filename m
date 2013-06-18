From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next 3/3] net: Add missing dependencies on NETDEVICES
Date: Tue, 18 Jun 2013 04:37:17 +0100
Message-ID: <1371526637.3495.116.camel@deadeye.wl.decadent.org.uk>
References: <1371522107.3495.61.camel@deadeye.wl.decadent.org.uk>
	 <1371523025.3495.68.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-SWvib9UcF4fJVgY5hr1c"
Cc: netdev <netdev@vger.kernel.org>, linux-cris-kernel@axis.com,
	Chad Williamson <chad@dahc.us>,
	Daniel Cotey <puff65537@bansheeslibrary.com>,
	devel@driverdev.osuosl.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:51666 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753952Ab3FRDh1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 23:37:27 -0400
In-Reply-To: <1371523025.3495.68.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-SWvib9UcF4fJVgY5hr1c
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2013-06-18 at 03:37 +0100, Ben Hutchings wrote:
> ETRAX_ETHERNET selects ETHERNET and MII, which depend on NETDEVICES.
> I don't think anything should select NETDEVICES, so make it a
> dependency.  It also doesn't need to select or depend on ETHERNET,
> which has nothing to do with the Ethernet library functions.
>=20
> BPCTL selects MII, which depends on NETDEVICES.  But everything in the
> drivers/staging/silicom directory is related to net devices, so make
> NET_VENDOR_SILICOM depend on NETDEVICES and remove the now-redundant
> dependencies on NET.
>=20
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> ---
> There are still a few staging dr
...ivers that are for net devices, yet don't depend on NETDEVICES.

Ben.

--=20
Ben Hutchings
Humans are not rational beings; they are rationalising beings.

--=-SWvib9UcF4fJVgY5hr1c
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUb/V7ee/yOyVhhEJAQrW/g//SPWpUyS5mR1NEXmL2KWbK8NQJK9VrrN4
sFKKEgFBj07NMsAYcq7/lJqDEgIGYAxC9duqSjUPNbxPehL4OCJYeF/Db70k11Rr
g63HYAxqOv+YSrzuamJ581Rfx21rJlfc0qpeRdEy8JiWyPGtknMJZPFMId/Krq0E
SQGuAxQsppa7Ot2u1GSXukWDZX+2567SkVgm0rnrdJhB9t0rf3fhXAOFadvAjqCR
8hWNBxOV0iCgM5/3E7lc1E98IKf3jDBu5QGr31oZ0ScQTUdf++L5ZTWxUYfbSAue
iaMiLBuLF6SxuxFwtZaIZU3cAXYQFyZmsfmmt9gorQjWBmf7yZWeRITaKtDIBiY4
BQ2o46CsUovXMgkWFTt8c/GvcWTXf2EaHxWKCgYNx4lxeK3+I1PwGd29nXggcGRo
m5OzLGTbsrhtn/AUNHSqac204xqE50InFoqYht6nV8foRoGSFtHG3F6ft2gwqNqf
uLOTy6EwqMOT9dLWGiNf+1nGQBJTQUHmWCDBa+BknJ4rjBdPfHbqroNjaE382va6
CIz2uvGtXb3MH30FEmTmy1FLG83nD9OQqz86YgWl6ygtaLk9ghKl7YeOFrYl4a1l
iczfC9bT5QMHs2m2PGgmVgKFxUyW4evJvqlbTJByz0U13k+meJFLjc9wxMr9JjKD
SkEsOq1gdaA=
=I3t4
-----END PGP SIGNATURE-----

--=-SWvib9UcF4fJVgY5hr1c--
