From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH V1 4/4] can: m_can: allow to send std frame on CAN FD
 mode
Date: Wed, 05 Nov 2014 11:41:34 +0100
Message-ID: <5459FEDE.9050405@pengutronix.de>
References: <1415174326-6623-1-git-send-email-b29396@freescale.com> <1415174326-6623-4-git-send-email-b29396@freescale.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="8mfk62x5dMTtLWV1KSJO16IGvwiHSeWWx"
Cc: wg@grandegger.com, varkabhadram@gmail.com, netdev@vger.kernel.org,
	socketcan@hartkopp.net, linux-arm-kernel@lists.infradead.org
To: Dong Aisheng <b29396@freescale.com>, linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1415174326-6623-4-git-send-email-b29396@freescale.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--8mfk62x5dMTtLWV1KSJO16IGvwiHSeWWx
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/05/2014 08:58 AM, Dong Aisheng wrote:
> The current code sends all CAN frames on CAN FD format(with BRS or not)=

> if CAN_CTRLMODE_FD is enabled.
> However, even CAN_CTRLMODE_FD is enabled, the can tool may still
> send normal frames.
> e.g.
> ip link set can0 up type can bitrate 1000000 dbitrate 1000000 fd on
> cansend can0 123#112233
>=20
> Therefore sending normal CAN frame on FD format seems not reasonable
> and the CAN FD incapable device may not be able to receive it correctly=
=2E
>=20
> The patch switches the M_CAN operation mode to ISO11898-1 instead of
> staying on CAN FD operation mode by writing "11" to CMR bit if find
> we're sending a normal can skb.

With this patch applied and Olivre's version of 3/4, how does the
application send CAN-FD frames?
1. witch on CAN-FD via "ip fd on"
2. write a struct canfd_frame

Correct?

What happens if:
3. write a struct can_frame

A CAN frame is send?

Oliver are you okay with this behaviour?

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--8mfk62x5dMTtLWV1KSJO16IGvwiHSeWWx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUWf7eAAoJECte4hHFiupUWrgP/3ygsf7y3Zb+hC9lbiPdYp5i
RQ0yofgF67Ffypg/sXAKMd825kZn6Jp65p+PYkzec13LolkzOTeefthx1GprYVzP
YM9BBmBGGXvZ4kaEMc7ZX2BAAPqvYmazRt+CfmSZGwE+otbKVHphUKEnoK9X2iD3
jJTTHDYhwvfuXaKaynEXXfYIiPwju9HwwVyeHt01NnKWLZtZLXA4CNyJwdaY5Ndq
tl9e5Q/zBMp4TsQXpIOkDoHMEsUnBD9vjgbQYlKTMbfDP7k2LjnwJ40RClUnEydt
voCKcg7rhu8Vhi5vjOyfWffDp9jBgbWAf+UDZmaZ7bChDbc2P6VJ4izrBX0e/oa6
ecwuc0Uctm0s35euyf9iufjhfuWJqx3LN0MashykGiyDyc4ehCZR0F5Je6RWInMk
8CtTBb4C+tQduYqrho7aM3W0bmizz6kb7x2fS6UZ1Ax7BVeSeHQjD9wfNY/IFDd1
IT3uwBcSpwRbHMS31m/vM2AOiK2pZKpqwvdInvh3dXCyczoKNAoXfuVwZ5rNutlg
0B1sSY+xvoJz01Q5+hDqUVK/y0p1M9t2xwPn+cPwhOegp4dnTu2/1jSqjavNzz+h
FidB+FYC4upOJTCRoR6rkp22RiUTfzBO3FbEQLk81aeBSwNnyyTk8WcbjzHqxhmU
WAO+g4UbjRrHPapfZvXy
=uQvh
-----END PGP SIGNATURE-----

--8mfk62x5dMTtLWV1KSJO16IGvwiHSeWWx--
