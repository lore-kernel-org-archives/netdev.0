From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [patch] can: c_can: precedence error in c_can_chip_config()
Date: Tue, 12 Jun 2012 11:37:29 +0200
Message-ID: <4FD70DD9.4010009@pengutronix.de>
References: <20120609155150.GA6488@elgon.mountain> <4FD4DEF2.6070802@pengutronix.de> <4FD62E21.3020209@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig1AD2A6F0A8D88757976B66E6"
Cc: Dan Carpenter <dan.carpenter@oracle.com>,
	Wolfgang Grandegger <wg@grandegger.com>,
	AnilKumar Ch <anilkumar@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Kosina <jkosina@suse.cz>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:52191 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752682Ab2FLJhy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 05:37:54 -0400
In-Reply-To: <4FD62E21.3020209@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig1AD2A6F0A8D88757976B66E6
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

Can I add your Acked-by ... when adding to net?

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig1AD2A6F0A8D88757976B66E6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk/XDdkACgkQjTAFq1RaXHNXaQCfc021vSacXyaYlFjTpWep0kdw
kuAAn1T2K7svEH6XZMWiQcSzzo7hD/hf
=zD3e
-----END PGP SIGNATURE-----

--------------enig1AD2A6F0A8D88757976B66E6--
