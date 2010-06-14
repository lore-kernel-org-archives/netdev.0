From: =?ISO-8859-15?Q?Thomas_B=E4chler?= <thomas@archlinux.org>
Subject: Re: [2.6.35-rc3 regression] TCP connections on 'lo' interface randomly
 stall
Date: Mon, 14 Jun 2010 21:36:05 +0200
Message-ID: <4C1684A5.1050705@archlinux.org>
References: <4C167093.2030308@archlinux.org> <20100614112319.9a2758f2.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="------------enig61395B3B7D5AAB741C96C400"
Cc: "David S. Miller" <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gerolde.archlinux.org ([66.211.214.132]:52845 "EHLO
	archlinux.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753740Ab0FNTgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jun 2010 15:36:11 -0400
In-Reply-To: <20100614112319.9a2758f2.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig61395B3B7D5AAB741C96C400
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

Am 14.06.2010 20:23, schrieb Randy Dunlap:
> On Mon, 14 Jun 2010 20:10:27 +0200 Thomas B=E4chler wrote:
>=20
>> With 2.6.35-rc3, I cannot use TCP over the 'lo' interface any more. Th=
is
>> is reproduced easily by running 'ssh localhost' and executing a few
>> commands inside the ssh session (if you are able to log in, 'ls -lhFR =
/'
>> does a good job) - the connection will stall completely after a very
>> short time. As far as I can see, all applications are affected.
>>
>> It also seems that once a service is "stalled", I cannot open a new
>> connection to the same TCP port anymore. However, I can open a
>> connection to a different port until that one is stalled, too.
>>
>> Running wireshark, I can see that TCP retransmissions are sent, but
>> never acknowledged.
>>
>> Bisection (starting with 7908a9e as good and v2.6.35-rc3 as bad) leads=

>> to the following commit. Please CC me on replies to this issue. Thanks=

>> for your help.
>=20
> Does this patch fix it for you?
> http://lkml.org/lkml/2010/6/13/155

Yes, it seems to fix it. Thanks.


--------------enig61395B3B7D5AAB741C96C400
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEAREIAAYFAkwWhKUACgkQEda5KzHP/VBZZgCgzF/P12iv5i71688GBkixwoyj
wvIAn1Oqe7rJ868YXDCQZPsTDsA+7Bzc
=mYy7
-----END PGP SIGNATURE-----

--------------enig61395B3B7D5AAB741C96C400--
