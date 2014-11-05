From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH V3 3/3] can: m_can: workaround for transmit data less
 than 4 bytes
Date: Wed, 05 Nov 2014 15:29:37 +0100
Message-ID: <545A3451.2090302@pengutronix.de>
References: <1415193393-30023-1-git-send-email-b29396@freescale.com> <1415193393-30023-3-git-send-email-b29396@freescale.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="30LlXH8aOD0Wqm92JB6ehnQGhBM1l2PNK"
Cc: wg@grandegger.com, varkabhadram@gmail.com, netdev@vger.kernel.org,
	socketcan@hartkopp.net, linux-arm-kernel@lists.infradead.org
To: Dong Aisheng <b29396@freescale.com>, linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1415193393-30023-3-git-send-email-b29396@freescale.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--30LlXH8aOD0Wqm92JB6ehnQGhBM1l2PNK
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/05/2014 02:16 PM, Dong Aisheng wrote:
> At least on the i.MX6SX TO1.2 with M_CAN IP version 3.0.1, an issue wit=
h
> the Message RAM was discovered. Sending CAN frames with dlc less
> than 4 bytes will lead to bit errors, when the first 8 bytes of
> the Message RAM have not been initialized (i.e. written to).
> To work around this issue, the first 8 bytes are initialized in open()
> function.
>=20
> Without the workaround, we can easily see the following errors:
> root@imx6qdlsolo:~# ip link set can0 up type can bitrate 1000000
> [   66.882520] IPv6: ADDRCONF(NETDEV_CHANGE): can0: link becomes ready
> root@imx6qdlsolo:~# cansend can0 123#112233
> [   66.935640] m_can 20e8000.can can0: Bit Error Uncorrected
>=20
> Signed-off-by: Dong Aisheng <b29396@freescale.com>

Applied to can/master

Thanks,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--30LlXH8aOD0Wqm92JB6ehnQGhBM1l2PNK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUWjRRAAoJECte4hHFiupUDHAQAJ+4ZJ4klnGUhHyvmRy32kWJ
Mdds7ZOJXVJ7YWHJwysnumMibLwgOJhIXw890KTlz1nHMQeR3rstiaPvqOEuJTrv
kw+uZ1rAQNeMBH38w7Ltk+8w5F9hT6ns9cMNHPuW5UjiY0zIBoBbgaCJNmSfHeD2
tB9P9fhvui5ED6hTRqQOUplqJQYP2NbTe0RIBuMJQapV45H//L8WCVyw52doEnNA
0fWb62a7vy+7H4xEgOVJVyTXsACYIHv0tNq4b2vtI5zPOlxUE/00eODxuWJgm7H5
A+7sHDuiUTQ8df+sdOCf/JteyBuh0Ee0iLiiNF/3WX+xX4ABaiTHzGtQwFCIYeTf
fudr5Ng/aNoWvNNQaU6M7lXdtJSnDDrUqUszFRftNO+8G9/KXLeVWX8OhSjhYr5b
K7xd0+MV5uWKv55o+yN/AxG0mQxvuiZOZ08BYQrfQBWL8G0nP+Kuv68Kpu2fyAkX
NEHLPXDScN5WEXj0yTZ7whHMRSdRvGYaaKfEWEyiT4q6TMwWLI934Tnfq8XEVDW/
tY1YLSLGWYDuHpnh3WZ7KMJu1nHLKncKoc//vLyftjGcmJBej+ISQqZPHif6WtSF
LdSPp3pqc90k0VbZ+jB85OzqI/7aI6m1a4rQ2xb1kv0IXcKsGcjY6uH0vA3ACiMp
s/+AZ8ukvWMgGgnEASsd
=XgR+
-----END PGP SIGNATURE-----

--30LlXH8aOD0Wqm92JB6ehnQGhBM1l2PNK--
