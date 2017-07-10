From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: CAN-FD Transceiver Limitations
Date: Mon, 10 Jul 2017 16:58:28 +0200
Message-ID: <6f9f7a0b-ff9d-15bd-47be-012986a452c3@pengutronix.de>
References: <de1f6343-4b28-4a5f-c6df-4e54c09fcce2@ti.com>
 <20170629142142.GF9244@lunn.ch> <5d4f2bcf-bd0f-4fa1-5d5a-d7b4a83cbc5e@ti.com>
 <20170629154139.GC13221@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="Iqx4qef1IiqKu9KNPaTs6mCbafp6NrHqs"
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
        wg@grandegger.com
To: Andrew Lunn <andrew@lunn.ch>, Franklin S Cooper Jr <fcooper@ti.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20170629154139.GC13221@lunn.ch>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Iqx4qef1IiqKu9KNPaTs6mCbafp6NrHqs
Content-Type: multipart/mixed; boundary="PCX4K4U7FwPABNrrmrk8RTqqISHMq6cpq";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Andrew Lunn <andrew@lunn.ch>, Franklin S Cooper Jr <fcooper@ti.com>
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org, wg@grandegger.com
Message-ID: <6f9f7a0b-ff9d-15bd-47be-012986a452c3@pengutronix.de>
Subject: Re: CAN-FD Transceiver Limitations
References: <de1f6343-4b28-4a5f-c6df-4e54c09fcce2@ti.com>
 <20170629142142.GF9244@lunn.ch> <5d4f2bcf-bd0f-4fa1-5d5a-d7b4a83cbc5e@ti.com>
 <20170629154139.GC13221@lunn.ch>
In-Reply-To: <20170629154139.GC13221@lunn.ch>

--PCX4K4U7FwPABNrrmrk8RTqqISHMq6cpq
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 06/29/2017 05:41 PM, Andrew Lunn wrote:
>> Transceivers for CAN are not apart of any model. Traditional CAN didn'=
t
>> have a problem because all transceivers from my understanding supporte=
d
>> the maximum speed of 1 Mbps defined by the spec. However, with the
>> introduction of CAN Flexible Datarate mode it seems that for
>> transceivers that supported CAN-FD the maximum supported speeds vary.
>=20
> So transceivers are dumb devices, nothing to configure, so no need to
> have a driver for them.

Yes and no.

CAN transceivers are usually quite dumb, but most of them have some sort
of "enable" pin. This pin is currently modelled as a regulator. Which
fits nicely, as there dual transceivers with only one enable pin.

However there are more complicated transceivers with two pins, that
implement a state machine, where you can query the chip for various
error conditions and can configure remote wakeup, etc... So in the
future a proper driver might be implemented.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--PCX4K4U7FwPABNrrmrk8RTqqISHMq6cpq--

--Iqx4qef1IiqKu9KNPaTs6mCbafp6NrHqs
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEE4bay/IylYqM/npjQHv7KIOw4HPYFAlljlhQACgkQHv7KIOw4
HPbjaAf/TlYcsNitUFRD1vWPOf5wocd7lupy1uzARq0tOgIqBtRT2T2MBlYH4awM
Kw26KjGP3/asGQo3/vAC3bMIfUwKEELFll6j/MNS5cBv6HQVqTZKJr6kpQkl1Trs
zf+esFZRllIlxy6T+at1xWn5n7ahkHGgdYpt+YEEcdlrvG+Wsoej1wdXhpZXwcSK
rd8YzQgWN8l5pNFQtdeaX9G1t2RvxgxOqv9sBTATR1OEXhzpOiiMMDdvKCIaqEcj
t9KhyNLB6ZF6VEHfSzrcCbTnipRe9aeFEjo5iLFwvYTVcK8UOAqfs/2QMn0SssCU
x6DxLSOfP5blM0+s8EnuEGeVya6tfw==
=jNhR
-----END PGP SIGNATURE-----

--Iqx4qef1IiqKu9KNPaTs6mCbafp6NrHqs--
