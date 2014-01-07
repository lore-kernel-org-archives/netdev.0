From: Thomas Haller <thaller@redhat.com>
Subject: Re: [PATCH v2 0/2] ipv6 addrconf: add IFA_F_NOPREFIXROUTE flag to
 suppress creation of IP6 routes
Date: Tue, 07 Jan 2014 22:42:37 +0100
Message-ID: <1389130957.2248.18.camel@weing>
References: <1389029375-17698-1-git-send-email-thaller@redhat.com>
	 <1389105553-21230-1-git-send-email-thaller@redhat.com>
	 <20140107160328.GF24730@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-yQL8X2E+sv9ZYLJ8v1tc"
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	stephen@networkplumber.org, dcbw@redhat.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31842 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753493AbaAGVmt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jan 2014 16:42:49 -0500
In-Reply-To: <20140107160328.GF24730@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-yQL8X2E+sv9ZYLJ8v1tc
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-01-07 at 17:03 +0100, Hannes Frederic Sowa wrote:
> On Tue, Jan 07, 2014 at 03:39:11PM +0100, Thomas Haller wrote:
> > Now, the IFA_F_NOPREFIXROUTE flag is saved in ifp->flags.
> > The second patch reworks the deletion of addresses/cleanup of prefix
> > routes and considers IFA_F_NOPREFIXROUTE.
> >=20
> > Thomas Haller (2):
> >   ipv6 addrconf: add IFA_F_NOPREFIXROUTE flag to suppress creation of
> >     IP6 routes
> >   ipv6 addrconf: don't cleanup route prefix for IFA_F_NOPREFIXROUTE
>=20
> Maybe you could look into if a small patch implementing noprefixroute wou=
ld be
> doable. That would help testing these changes a lot. ;)
>=20
> Greetings,
>=20
>   Hannes
>=20

Just for reference:

I sent an email "[patch iproute2 v3 3/3] add support for IFA_F_NOPREFIXROUT=
E"
with a patch for iproute2.


Thomas



--=-yQL8X2E+sv9ZYLJ8v1tc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABAgAGBQJSzHTNAAoJECnCNm5N/FcoBdkQAJcEP9svoRFfkljKYgMeJE4w
+IKe0Rr6BKlmCSGyYkP+AwTz65LWY48LA+XPKhfV7FA9/jNFPoNOTj9BZWHLEcbx
MMv4+H+oBbJNPrFVAn3JYSYbONefpsoG6EFunkppwuMrNbtyPN1O9pb0z+81YipV
ykl5V1wjnfS8+PAF4RQUCNOQ6I4PVu1B+ZGUOEIF6PLbwQWOP+DothJFDgEQEpR8
cEYCEtRGkBbyw5h8cAUeZrqACtl8Bfd+OT9yjY77s6S7ufNJy5qOzC9UCMG3Dytl
/Se7u8YGFOWGo1pX1ear5alfN4GtBp5oowUGk+gillZz7mfRHSsA+vM2DrWkrqiN
2G9q84CCbo9IhYYeuuxQXgLTOHq26Lr0svZYYI0qHSwcxNVEZbeWYGDwaVdIhFjV
PN7LoUBobYsmcAeLGzmEI17usy3Sr9awKi2MKzkCx9uNVLr4im30n76D8f5ambsf
FhNKGAQjs6rAPO2DtTzzV2m5E3Wwmx9P2MRoxeZMzLSlwHrvKV+3IHlP2KtnUCmI
1ugPBBWgF+T0aToLragr4h2aJW/YPkq1iiLVIPs/6Wr2VkQ3qotfY+enjrizYPDf
ziO5B13vvPxBpH6j4Yt7kyYPng7waa8hjPV/Q2xVHM3uRdVnFE60di3czoBLJ4ol
KOAeW0khV0thKWv02l1A
=QKbx
-----END PGP SIGNATURE-----

--=-yQL8X2E+sv9ZYLJ8v1tc--
