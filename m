From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 2/2] flexcan: Fix CAN_RAW_RECV_OWN_MSGS and CAN_RAW_LOOPBACK
Date: Thu, 03 Nov 2011 11:17:57 +0100
Message-ID: <4EB26A55.6010207@pengutronix.de>
References: <70F6AAAFDC054F41B9994A9BCD3DF64E16FAA8E0@exch01-aklnz.MARINE.NET.INT> <1320313675-30749-1-git-send-email-mkl@pengutronix.de> <1320313675-30749-3-git-send-email-mkl@pengutronix.de> <4EB26702.60506@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig666DB3A492637A04FFAEDCBD"
Cc: kurt.van.dijck@eia.be, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, Reuben.Dowle@navico.com
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:40313 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751346Ab1KCKSE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2011 06:18:04 -0400
In-Reply-To: <4EB26702.60506@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig666DB3A492637A04FFAEDCBD
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 11/03/2011 11:03 AM, Oliver Hartkopp wrote:
> On 03.11.2011 10:47, Marc Kleine-Budde wrote:
>=20
>> @@ -609,9 +605,10 @@ static irqreturn_t flexcan_irq(int irq, void *dev=
_id)
>> =20
>>  	/* transmission complete interrupt */
>>  	if (reg_iflag1 & (1 << FLEXCAN_TX_BUF_ID)) {
>> -		/* tx_bytes is incremented in flexcan_start_xmit */
>> +		stats->tx_bytes +=3D can_get_echo_skb(dev, 0);
>>  		stats->tx_packets++;
>>  		flexcan_write((1 << FLEXCAN_TX_BUF_ID), &regs->iflag1);
>> +		can_get_echo_skb(dev, 0);
>>  		netif_wake_queue(dev);
>>  	}
>=20
>=20
> What's the reason for the second can_get_echo_skb() here?
doh!

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig666DB3A492637A04FFAEDCBD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk6yalcACgkQjTAFq1RaXHNpCwCgmPcg5j1RXsonn+1Vn7LUfkE8
ibQAn0pYADO03LgK2bc9C5pKS0PmSFO5
=hEeX
-----END PGP SIGNATURE-----

--------------enig666DB3A492637A04FFAEDCBD--
