From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v5] can: add Renesas R-Car CAN driver
Date: Mon, 20 Jan 2014 12:47:13 +0100
Message-ID: <52DD0CC1.70205@pengutronix.de>
References: <201312270037.15822.sergei.shtylyov@cogentembedded.com> <CAMuHMdWZJUvcW9OzM39aB2m+VdKqmZ6EOGR_rZcAdV7Cmwx3kg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="5pvnuu9f5L2gjpckVidOAb2fF86L26aNW"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	wg@grandegger.com, linux-can@vger.kernel.org,
	Linux-sh list <linux-sh@vger.kernel.org>, vksavl@gmail.com
To: Geert Uytterhoeven <geert@linux-m68k.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdWZJUvcW9OzM39aB2m+VdKqmZ6EOGR_rZcAdV7Cmwx3kg@mail.gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--5pvnuu9f5L2gjpckVidOAb2fF86L26aNW
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 01/20/2014 12:43 PM, Geert Uytterhoeven wrote:
> Hi Sergei,
>=20
> On Thu, Dec 26, 2013 at 10:37 PM, Sergei Shtylyov
> <sergei.shtylyov@cogentembedded.com> wrote:
>> Changes in version 3:
>=20
>> - added '__packed' to 'struct rcar_can_mbox_regs' and 'struct rcar_can=
_regs';
>> - removed unneeded type cast in the probe() method.
>=20
>> +/* Mailbox registers structure */
>> +struct rcar_can_mbox_regs {
>> +       u32 id;         /* IDE and RTR bits, SID and EID */
>> +       u8 stub;        /* Not used */
>> +       u8 dlc;         /* Data Length Code - bits [0..3] */
>> +       u8 data[8];     /* Data Bytes */
>> +       u8 tsh;         /* Time Stamp Higher Byte */
>> +       u8 tsl;         /* Time Stamp Lower Byte */
>> +} __packed;
>=20
> Sorry, I missed the earlier discussion, but why the _packed?
> One u32 and 12 bytes makes a nice multiple of 4.

Better safe than sorry, it's the layout of the registers in hardware,
don't let the compiler optimize here.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--5pvnuu9f5L2gjpckVidOAb2fF86L26aNW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlLdDMEACgkQjTAFq1RaXHO+dQCfQzgPHEgMko9Aqv6jet1CwdU9
qfEAn1lwT8tai+Ary25PpCuOLgUZs8I4
=rDFG
-----END PGP SIGNATURE-----

--5pvnuu9f5L2gjpckVidOAb2fF86L26aNW--
