From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: M_CAN message RAM initialization AppNote  - was: Re: [PATCH V3
 3/3] can: m_can: workaround for transmit data less than 4 bytes
Date: Thu, 06 Nov 2014 13:47:20 +0100
Message-ID: <545B6DD8.6010906@pengutronix.de>
References: <1415193393-30023-1-git-send-email-b29396@freescale.com> <1415193393-30023-3-git-send-email-b29396@freescale.com> <545A3451.2090302@pengutronix.de> <545A692E.40002@hartkopp.net> <20141106015716.GB7642@shlinux1.ap.freescale.net> <545B1D71.4000408@hartkopp.net> <20141106080940.GA22964@shlinux1.ap.freescale.net> <545B6AB4.70003@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="9UrCQKUT0KoLh6C24V8S3x7dSjBiFOSJN"
Cc: linux-can@vger.kernel.org, wg@grandegger.com,
	varkabhadram@gmail.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Oliver Hartkopp <socketcan@hartkopp.net>,
	Dong Aisheng <b29396@freescale.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <545B6AB4.70003@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--9UrCQKUT0KoLh6C24V8S3x7dSjBiFOSJN
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/06/2014 01:33 PM, Oliver Hartkopp wrote:
>> So i'm not sure memset() the entire TX FIFO element is neccesary...
>=20
> It's no big deal - so we should be defensive here.
> And memset() is not working as Marc pointed out in another mail.
>=20
> So we would need to loop with
>=20
>     m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(i), 0x0);
>=20
>>
>> Do you think we could keep the current solution firstly and updated la=
ter
>> if needed?
>=20
> No :-)
>=20
> I would like to have all data bytes to be written at startup.

Me, too. As this happens only once during ifconfig up it should not hurt
performance, either send an incremental or new patch. I'll sort it out.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--9UrCQKUT0KoLh6C24V8S3x7dSjBiFOSJN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUW23YAAoJECte4hHFiupUGm0QAKl7VeBNmfSqjliLbRciZxAR
5YgLyXQd9rwTO1TpVs7WX6f3YjiNFBL0Gp+p++LTK6cIF9EHUE8PRvBUt3dsItRf
aYjLq/u/hkamWr3WSwT3evUpZYlgGHlVtJ7XJoJxaQG/yQulLNKSRl2PpMHumO8n
v8C4QwZQcq+YjLNyAt/m/ruIRWRefeOkFDxOQi8M6us5rIsLmeKpcLMY/7BzCRZb
jdC5fW6AM7CyA3bZfZmi7P/FcnySEUg3mwUSiTo4IkJLNxo7M1Yb4eYwc8cIUg+o
1I8shs7DAhCghCOY0nBH7Oa/7DBwrdw25kQyPb9WWnG5U+lC6dK78lc4DbaCgutp
t18DqWy017sQTYuaSMeapl8hA/170UAU65kUoZlAIukoNgaZ3LriY1xnN82vdlof
Q7k7dVvaXp5YbQabd46a5YmFEg0GqGg7Ai+qHzitP0kwBZwl6zMY3xa/N/AwBc6d
EWHmnJhQur5RTpv6DtLhO45kRZv9wEO63TdWb0jwqXeOH6GomBeErJAlimPH389S
iqukVFUqtSK2g3Mmj1Ssg6BeLYeci49TP+BWurDZ9FQCHp2EqvaE4QXUM4S8olm7
OXj0PGqB+oXVSeQMSpnW3AxTzR7UXQFOVhaG5LYLmbJFsZkzJ9rrB+0ocdXWzcBf
+UUkRM8G1ctwBpL9tI3Q
=nFch
-----END PGP SIGNATURE-----

--9UrCQKUT0KoLh6C24V8S3x7dSjBiFOSJN--
