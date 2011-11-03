From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 0/2] clean up tx_bytes accounting
Date: Thu, 03 Nov 2011 11:42:46 +0100
Message-ID: <4EB27026.90301@pengutronix.de>
References: <70F6AAAFDC054F41B9994A9BCD3DF64E16FAA8E0@exch01-aklnz.MARINE.NET.INT> <1320313675-30749-1-git-send-email-mkl@pengutronix.de> <20111103100333.GD317@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig564E1C69008B5819EDE655C7"
To: socketcan@hartkopp.net, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, Reuben.Dowle@navico.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:59655 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932216Ab1KCKmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2011 06:42:50 -0400
In-Reply-To: <20111103100333.GD317@e-circ.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig564E1C69008B5819EDE655C7
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/03/2011 11:03 AM, Kurt Van Dijck wrote:
> On Thu, Nov 03, 2011 at 10:47:53AM +0100, Marc Kleine-Budde wrote:
>> Hello,
>>
>> what about turning can_get_echo_skb() into a helper function which ret=
urns the number
>> of tx'ed bytes.
> That would work.
>=20
> Next step would be to do the statistics inside can_get_echo_skb(), but =
that's
> affecting all drivers using it ...
> Kurt

Interesting idea

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig564E1C69008B5819EDE655C7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk6ycCkACgkQjTAFq1RaXHPNuACeKqWNP3E0ELafQAf1/HACOHth
GQ8An1o2sjTdkWE/3TNyjvAXlTf4D5i4
=PubU
-----END PGP SIGNATURE-----

--------------enig564E1C69008B5819EDE655C7--
