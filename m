From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [PATCH 6/7] net: Add vbus_enet driver
Date: Mon, 03 Aug 2009 16:10:37 -0400
Message-ID: <4A77443D.9020105@novell.com>
References: <20090803171030.17268.26962.stgit@dev.haskins.net>	<20090803171801.17268.93846.stgit@dev.haskins.net> <20090803113030.3092d5b0@nehalam>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigD52A438717C62368A4E11228"
Cc: linux-kernel@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751831AbZHCUK5@vger.kernel.org>
In-Reply-To: <20090803113030.3092d5b0@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigD52A438717C62368A4E11228
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Stephen Hemminger wrote:
> On Mon, 03 Aug 2009 13:18:02 -0400
> Gregory Haskins <ghaskins@novell.com> wrote:
>=20
>> +
>> +static const struct net_device_ops vbus_enet_netdev_ops =3D {
>> +	.ndo_open          =3D vbus_enet_open,
>> +	.ndo_stop          =3D vbus_enet_stop,
>> +	.ndo_set_config    =3D vbus_enet_config,
>> +	.ndo_start_xmit    =3D vbus_enet_tx_start,
>> +	.ndo_change_mtu	   =3D vbus_enet_change_mtu,
>> +	.ndo_tx_timeout    =3D vbus_enet_timeout,
>> +};
>=20
>=20
> Missing=20
> 	.ndo_set_mac_address =3D eth_mac_addr,
> 	.ndo_validate_addr   =3D eth_validate_addr,
>=20

Ack.

> Also, should have change_mtu.

note that I do have .ndo_change_mtu.  I assume this is what you are
referring to and just missed it.  If there is something else I need
there, let me know.

Kind Regards,
-Greg


--------------enigD52A438717C62368A4E11228
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkp3RD0ACgkQP5K2CMvXmqEUpwCeJedJMaWHWrCUO54/C6GyXnJM
/oQAnA7Xs8b+QoqC3AmirBbNa5PnIyMq
=1thO
-----END PGP SIGNATURE-----

--------------enigD52A438717C62368A4E11228--
