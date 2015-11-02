From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [RFC][PATCH] net: arinc429: Add ARINC-429 stack
Date: Mon, 2 Nov 2015 10:47:44 +0100
Message-ID: <56373140.6040003@pengutronix.de>
References: <1446419775-5215-1-git-send-email-marex@denx.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="fBGBO6afFQ3iUwXoo9Ixo6EnwArN0fwr2"
Cc: "David S. Miller" <davem@davemloft.net>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Andrey Vostrikov <andrey.vostrikov@cogentembedded.com>
To: Marek Vasut <marex@denx.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:48331 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751576AbbKBJsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 04:48:07 -0500
In-Reply-To: <1446419775-5215-1-git-send-email-marex@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--fBGBO6afFQ3iUwXoo9Ixo6EnwArN0fwr2
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 11/02/2015 12:16 AM, Marek Vasut wrote:
> The ARINC-429 is a technical standard, which describes, among others,
> a data bus used by airplanes. The standard contains much more, since
> it is based off the ISO/OSI model, but this patch implements just the
> data bus protocol.
>=20
> This stack is derived from the SocketCAN implementation, already presen=
t
> in the kernel and thus behaves in a very similar fashion. Thus far, we
> support sending RAW ARINC-429 datagrams, configuration of the RX and TX=

> clock speed and filtering.
>=20
> The ARINC-429 datagram is four-byte long. The first byte is always the
> LABEL, the function of remaining three bytes can vary, so we handle it
> as an opaque PAYLOAD. The userspace tools can send these datagrams via
> a standard socket.
>=20
> A LABEL-based filtering can be configured on each socket separately in
> a way comparable to CAN -- user uses setsockopt() to push a list of
> label,mask tuples into the kernel and the kernel will deliver a datagra=
m
> to the socket if (<received_label> & mask) =3D=3D (label & mask), other=
wise
> the datagram is not delivered.

What's difference compared to CAN besides a different MTU? The CAN stack
is already capable to handle CAN and CAN-FD frames. Would it make sense
to integrate the ARINC-429 into the existing CAN stack?

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |



--fBGBO6afFQ3iUwXoo9Ixo6EnwArN0fwr2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWNzFDAAoJEP5prqPJtc/Hj2AH/1BpaylyKUffLIDhvWttYgtG
GXR3ziX9n4QFZM5SDwQAMGNF7Y6FE6+bLUGUEZ8EbdI4Gk9gEm44AkJOnaSOfNSZ
e8u11Auj14QaeV5+BzENGbJ5w1Va1VxrFXspGj4iiHl/TztbxjAf3AambrHgdTFE
nERJ7baW2ox6OU/HTv8/RsPkY4tF0E+xWhIthVa020xrXH6hPhl7urtVgpn7/Fmw
FgIk5sMK59+y2FYupDXtgX+/NOH0pBS4ZVe2VO9E8u/W2ZsmQA5DTgE4smSClsNO
xV3PgYzFUbld53U1vvuPw5LYWv9WZNNWrqkT2kd6yRb7Ywx4Ckbff9mPSSSPxm4=
=itV1
-----END PGP SIGNATURE-----

--fBGBO6afFQ3iUwXoo9Ixo6EnwArN0fwr2--
