From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [patch] can: c_can: precedence error in c_can_chip_config()
Date: Mon, 11 Jun 2012 19:51:53 +0200
Message-ID: <4FD63039.4080104@pengutronix.de>
References: <20120609155150.GA6488@elgon.mountain> <4FD4DEF2.6070802@pengutronix.de> <4FD62E21.3020209@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigDA31BE94A4B1E4AEB3931963"
Cc: Dan Carpenter <dan.carpenter@oracle.com>,
	Wolfgang Grandegger <wg@grandegger.com>,
	AnilKumar Ch <anilkumar@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Kosina <jkosina@suse.cz>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:41742 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751007Ab2FKRwY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 13:52:24 -0400
In-Reply-To: <4FD62E21.3020209@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigDA31BE94A4B1E4AEB3931963
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 06/11/2012 07:42 PM, Oliver Hartkopp wrote:
> On 10.06.2012 19:52, Marc Kleine-Budde wrote:
>=20
>> On 06/09/2012 05:56 PM, Dan Carpenter wrote:
>>> (CAN_CTRLMODE_LISTENONLY & CAN_CTRLMODE_LOOPBACK) is (0x02 & 0x01) wh=
ich
>>> is zero so the condition is never true.  The intent here was to test
>>> that both flags were set.
>>>
>>> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>>> ---
>>> This is a static checker fix.  I'm not super familiar with the c_can
>>> code.
>>
>> Good catch. Applied to can-next.
>>
>> Marc
>>
>=20
>=20
> Shouldn't this fix go through the net-tree and stable instead of net-ne=
xt?

Indeed.

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigDA31BE94A4B1E4AEB3931963
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk/WMD4ACgkQjTAFq1RaXHPkcgCeIIbQjkQ1QGsFgnk6j7+eybnT
AIUAn1x7jjatrgp25sVlbVCPvp3KEVeC
=adXJ
-----END PGP SIGNATURE-----

--------------enigDA31BE94A4B1E4AEB3931963--
