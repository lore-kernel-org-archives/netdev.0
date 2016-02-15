From: Robert Sander <r.sander@heinlein-support.de>
Subject: Re: Configure ICMP error source address
Date: Mon, 15 Feb 2016 10:13:15 +0100
Message-ID: <56C196AB.5080403@heinlein-support.de>
References: <568F8207.9040305@heinlein-support.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="m9DWpMgi1JtEKTwMJipgPCktUTHEf1ugj"
To: netfilter@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.heinlein-support.de ([91.198.250.30]:41954 "EHLO
	mx3.heinlein-support.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751791AbcBOJTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 04:19:32 -0500
In-Reply-To: <568F8207.9040305@heinlein-support.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--m9DWpMgi1JtEKTwMJipgPCktUTHEf1ugj
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 08.01.2016 10:31, Robert Sander wrote:

> We have the situation that our routers use RFC1918 addresses on their
> transfer networks (which should be quite common nowadays to save on
> public IPv4 addresses). ICMP errors are generated with RFC1918 source
> addresses and therefor never reach the original sender.

A follow-up to this request:

It is much easier to accomplish when settings routes with a source
address that is a public IP like this:

ip route add default via 10.10.10.1 src 192.0.2.24

ICMP errors will then use 192.0.2.24 as the source address.

No need for a kernel patch. Thanks for all the input.

Regards
--=20
Robert Sander
Heinlein Support GmbH
Schwedter Str. 8/9b, 10119 Berlin

http://www.heinlein-support.de

Tel: 030 / 405051-43
Fax: 030 / 405051-19

Zwangsangaben lt. =C2=A735a GmbHG:
HRB 93818 B / Amtsgericht Berlin-Charlottenburg,
Gesch=C3=A4ftsf=C3=BChrer: Peer Heinlein -- Sitz: Berlin


--m9DWpMgi1JtEKTwMJipgPCktUTHEf1ugj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJWwZarAAoJEPC7kVgj3lsohsoQALzturAhgCT3vtJCsLIdu8U+
RpqrDBJ8SuLwjQ5F20FgMAZ+K0QF2399pdDH/CmT8vilbNNlI9Ty6asdgq3PDRSD
4WOpoHlQPHqJa3pWN1njGHDgDNxu3kFUDQnIE/XJMWWVz5qNqUaZ4XWZsrm96asq
982XY5Iwo3gJLDNQ1Gwrx3rBMJEjYGXupwFPH5T0kkNrTzEnmZBMdeAeoWM1GWA/
qTC//B2MmkLORFKoZ8h/Z6gUfd2WTpZrJtIdySIN7FC9ebfefwkBRh9+BLVECSSB
+eG0OjaMf6gcoKdd8zBYzh7b5gXEx6Uc/T6W/t1iRato41ipySB5EyLSpLN987wp
w4Ii9T+6hB9ACjWYFn3S0dNAp6394lpJSkep3TtQIkhmQiQsWhYFJ+k9KfVPvPHu
c/1tuVHxNQHtexPZ5usl9Bkxa1saYM4PWVfDvfdllT0asdwa5ERawmhK9lOjYGaU
nGlUDrAbZ9OusXKTvD+/1G2KJg5Ndj0gZFrhK1wS4eMm/ghbBPvbx1IMsP6fAtXX
7Eb9xEOM8SfgXv8Nyxq1lg5Npt5kjHmbXfEfM45MHDtBy1jV2ZCAGjpQl8kPHi2t
S8UxsL702VsfOK42eFMGlH4buoUU6OjM2rYz893mZW/1sEXnLDLgXl0R2M5CH3ki
J3VFY7AtVbGvdpsq7BSL
=uwg9
-----END PGP SIGNATURE-----

--m9DWpMgi1JtEKTwMJipgPCktUTHEf1ugj--
