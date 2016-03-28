From: Matthias Schiffer <mschiffer@universe-factory.net>
Subject: Re: RESEND: Easily reproducible kernel panic due to netdev
 all_adj_list refcnt handling
Date: Mon, 28 Mar 2016 23:31:34 +0200
Message-ID: <56F9A2B6.5090503@universe-factory.net>
References: <56CCDD4D.4080303@cradlepoint.com>
 <56F5A2D9.7090700@universe-factory.net> <56F5B746.9050401@cradlepoint.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="uCMugLtJtegAfDolAPr4cbO2A5N3dMbPE"
Cc: netdev@vger.kernel.org
To: Andrew Collins <acollins@cradlepoint.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chaos.universe-factory.net ([37.72.148.22]:49911 "EHLO
	chaos.universe-factory.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752548AbcC1Vbi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2016 17:31:38 -0400
In-Reply-To: <56F5B746.9050401@cradlepoint.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--uCMugLtJtegAfDolAPr4cbO2A5N3dMbPE
Content-Type: multipart/mixed; boundary="kwEtf7RE5D5LIB6ssuV7NmXhcGd0MSagx"
From: Matthias Schiffer <mschiffer@universe-factory.net>
To: Andrew Collins <acollins@cradlepoint.com>
Cc: netdev@vger.kernel.org
Message-ID: <56F9A2B6.5090503@universe-factory.net>
Subject: Re: RESEND: Easily reproducible kernel panic due to netdev
 all_adj_list refcnt handling
References: <56CCDD4D.4080303@cradlepoint.com>
 <56F5A2D9.7090700@universe-factory.net> <56F5B746.9050401@cradlepoint.com>
In-Reply-To: <56F5B746.9050401@cradlepoint.com>

--kwEtf7RE5D5LIB6ssuV7NmXhcGd0MSagx
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 03/25/2016 11:10 PM, Andrew Collins wrote:
> On 03/25/2016 02:43 PM, Matthias Schiffer wrote:
>> We've tried your patch, and it changes the symptoms a bit, but doesn't=
 fix
>> the panic. I've attached kernel logs of the crash both before and afte=
r
>> applying the patch.
>>
>> One note: I did not reproduce this issue myself, it was first reported=
 in
>> [1], and then forwarded to the batman-adv issue tracker [2] by me.
>>
>> Regards,
>> Matthias
>>
>>
>> [1] https://github.com/freifunk-gluon/gluon/issues/680
>> [2] https://www.open-mesh.org/issues/247
>=20
> On the off chance it helps, the version of the patch I integrated local=
ly
> takes a somewhat different approach
> than the one I sent to the mailing list (propagates adj_list refcnts). =

> I've attached it in case it's useful.
>=20
> I haven't submitted this upstream yet as it's still rather ugly.  I'm o=
f
> the opinion that the whole "every device
> knows every upperdev and lowerdev in its tree" model is rather broken, =
and
> the patch is just working around
> a design that needs some rework.
>=20
> Thanks,
> Andrew Collins

It's ugly, but it seems to help. No crashes so far with the new version o=
f
your patch.

Thanks,
Matthias


--kwEtf7RE5D5LIB6ssuV7NmXhcGd0MSagx--

--uCMugLtJtegAfDolAPr4cbO2A5N3dMbPE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJW+aK2AAoJEBbvP2TLIB2cceYP/0RAZwo3b8GiYyJsU72Tn5WV
NdXDIltHRRC3vAskPrhdrKepdyVxOHjD9ELp7wMgnMy1krocBvdVrOf2IOpCqPKk
UukaPx23v6+8j651xkwYiHhkeYVPBzaIWWsZC8da5bWKurniH3r67v/R8J/Qg7s8
wwEzKTShOEqgNwyRJr9/bN3K1nsiQGheI4q20YhmKlavT1vStmLA8pxYkypjo91R
C0zrWmsBpUCgj5yd8FVxCZSv8aQtGgsQTEc52RzBR3zryXQmAh2vLch07+9A7NlA
2OxJAyvjq2LbVP7Gp8baYI4zZw80UR4og0aBbwjKguwvD+ZYXxjseCu8jow2L4oE
eN1VyUSTGubkJzSChY2ifHJ9vh+mhyA8jljWhD5wvM6HMlDLJgbjMT7CLDRgvlhy
EIBVop7DEW7iyeYW2V6EdXvlCiaVOzCytT9oIVruO09S8SgHNHEXIwjKU+dDXB7w
A172wepvD5ILrWM124bKsD1tGeOYAIaLngtOPWDGslbSXEUOT4ikpz7KGobK11jO
Nvk6WQD+Gr2mTJwzQx/oilyHKeNHwEvudCQafZD64+ZxxtwOIHLdkIxeB9dlEwBu
zfdrl71bCqqjhCY1ZGZ0zlZ4CKzHhJ+G6mxYiluJR86bWbdjlf5rlVtMXuHoh6cZ
r+SnY5TI6qR4oBrIiphY
=D18V
-----END PGP SIGNATURE-----

--uCMugLtJtegAfDolAPr4cbO2A5N3dMbPE--
