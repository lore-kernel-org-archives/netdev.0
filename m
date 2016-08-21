From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [net-next PATCH] ethtool: Add support for SCTP verification tag
 in Rx NFC
Date: Sun, 21 Aug 2016 01:21:50 +0100
Message-ID: <1471738910.13300.114.camel@decadent.org.uk>
References: <147164234934.15412.10180837031828143039.stgit@ahduyck-desk.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-38ySb54XY88GdBQi8VNc"
Cc: davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:44247 "EHLO
        shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751532AbcHUAWA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 20 Aug 2016 20:22:00 -0400
In-Reply-To: <147164234934.15412.10180837031828143039.stgit@ahduyck-desk.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-38ySb54XY88GdBQi8VNc
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-08-19 at 14:32 -0700, Alexander Duyck wrote:
> The i40e hardware has support for SCTP filtering via Rx NFC however the
> default configuration expects us to include the verification tag as a par=
t
> of the filter.=C2=A0=C2=A0In order to support that I need to be able to t=
ransfer that
> data through the ethtool interface via a new structure.
>=20
> This patch adds a new structure to allow us to pass the verification tag
> for IPv4 or IPv6 SCTP traffic.
[...]

This looks like an incompatible ABI change. =C2=A0I suppose it could be OK
if no drivers implemented flow steering for SCTP using the previously
specified structure, but have you checked that that is the case?

Ben.

--=20
Ben Hutchings
It's easier to fight for one's principles than to live up to them.

--=-38ySb54XY88GdBQi8VNc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXuPQeAAoJEOe/yOyVhhEJH+AQAJIh+igWRnnhHb8STgbr8dkv
JusD4KDyMOCVwYN+k5iUo1BmfCipW5AAppFHrQyuS/mGxq+q7nBVQ0l4j2u1ZBqr
b7SYaVaiD3j1Fv4aMDoELIBu4qarkW7CUNx297K/h2uUbv85OYY1/sdgzWNlCWZ9
jIVK+oIOK3MtHf25C87vpVb71MCoh9Nb262vtB/YwtcH1cMvalIH0J+QT14GddZH
IChgr1ePWT8kJm2t5WqUQk1Z/oJLMaxuqSMYLttrPMRFPqzMIcLTkqo3S2VEvwOk
Hz3bObdFuw0MBlFdntO6gJlcEYmMmnVyu6MgIwjJhlBMRaBC0lzVYWDvvZChMDDj
1r/PasG05jLXx0NB8vNhO8eRZ/FLbw39P9PsY8lIiLkgtj1OxCvdGrx6UlvBo6cw
Fuh3PDW6p9ycvkyOWM3ZXMlRPq1yhLDEv3KIzoS0qDm+YM5rH7vR4J4NcUBuT9eE
QJa0i9Vco/N8zkfBrRR/dL/6LV/yDI8VoxpSVkLXWy/wNguMb/mYIfLiN0b1tDLG
oJpeJ+WkX9z1XOK7sjjpEFQdhLL7vyUDNDl0aq/00DHoteSQscHZu8MbgQmnfDxx
PSdPmvCoJx+9Bc0dScpYJdif2Oil8tgoZhFDBTFOwM8rtftWo2rMGTpWMSpf0DeE
LPPelFFLW2rhSGJWYUAe
=Z9La
-----END PGP SIGNATURE-----

--=-38ySb54XY88GdBQi8VNc--
