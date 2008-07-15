From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: TXQ real_num_tx_queues comments/questions
Date: Tue, 15 Jul 2008 12:28:41 +0200
Message-ID: <1216117721.3535.22.camel@johannes.berg>
References: <1216114621.3535.18.camel@johannes.berg>
	 <20080715.023954.234208581.davem@davemloft.net>
	 <1216115349.3535.20.camel@johannes.berg>
	 <20080715.030531.227856924.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-gVWkmfCNxDFdNUoapZzi"
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:60764 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754797AbYGOK2o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 06:28:44 -0400
In-Reply-To: <20080715.030531.227856924.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-gVWkmfCNxDFdNUoapZzi
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2008-07-15 at 03:05 -0700, David Miller wrote:
> From: Johannes Berg <johannes@sipsolutions.net>
> Date: Tue, 15 Jul 2008 11:49:09 +0200
>=20
> > Yes, I think we can fix it by deferring the requeue to a workqueue,
> > using synchronize_net() and putting RCU protection against the
> > select_queue call.
>=20
> I'm respinning my net-tx-2.6 tree at the moment and I'll
> make patch 8 look like below.

Looks good to me, thanks.

johannes

--=-gVWkmfCNxDFdNUoapZzi
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJIfHvVAAoJEKVg1VMiehFYhlsP/3KgjsrUrCHtO+F6WHXap59E
9I1jrYz32bNQPt29Ccx9TcpkgGxba9Csyy99iCqhZ4wTLWWz+FAaQekGLIsUx0fq
0JBQ/fkkNX27UB0fsK2YhQ/0Pc+rqDjH/f+gS+uOdGqBYIhz0M+pSb6tgWIT+42D
8k6Zsz4NfGhdvrFScUW8lRmlIYTokSDRZEJ0L8o3WgOtNjoLwhyD8PCsBghzjY64
338aXO2lAJKAp5+88/mdLCpgWPR+VtoMecf0HIV6fDI0PCidc6iMNFg8XBVSqLIJ
QBbKwkQqfuuq7lZ0iYWSLZbYjH6UN0beIKhcaSE7BmfRk2cFglPisxIl9bSpCMPz
HDHd82vsfuZEJaA/QIZ95C+60ky6c0WgHziBioX6J/QLIH7dJ9Q7oISj7vKndiRx
7gn7eFm8SnNGK8cU4eiwEz09+/vRvJhqHwDXWl7Pw3VvIWIqNBJ7tnRbTw3l9GQt
0/InoqhHsDYcKucqrX7EeQT5V1PnUXsegSVk38QTlJLI6n33+lWjUoh4kjv8CpcN
eGnHAfuu3CqshmgVUB8H6/6XLwlkU8u+6hfYEXHtIjygdooqlga2pAhXP5P64qFa
AJuBhrSLmDR6NebRuVsI3I7RSkbdScgejR76+hxVYTbt/O5odwOLitFFt7RjUeYe
ss7aDUIzLuVe4rMmxoHV
=soc3
-----END PGP SIGNATURE-----

--=-gVWkmfCNxDFdNUoapZzi--

