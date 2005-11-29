From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: NIC irq nobody cared ? virtual to  physical  and DMA questions
Date: Tue, 29 Nov 2005 22:05:58 +0100
Message-ID: <200511292206.02147.IvDoorn@gmail.com>
References: <745843498.20051129212851@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1976923.1UqfYTiUxi";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kernel-mentors@selenic.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932401AbVK2U6K@vger.kernel.org>
To: Mateusz Berezecki <mateuszb@gmail.com>
In-Reply-To: <745843498.20051129212851@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1976923.1UqfYTiUxi
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi,

> This time the questions are different.
>=20
> Given the following output could anyone please tell me what is wrong ?
> In explicit what does that mysterious "nobody cared" message mean?
> And another stupid question: should DMA for a network card be enabled bef=
ore or maybe
> _after_ interrupts get enabled? And... how to convert virtual address
> to physical one?

The nobody cared error message is reported when a device is raising interru=
pts while
the actual driver has not yet registered the interrupt handler.

The best way to handle this for network drivers (done in rt2x00, which work=
s fine) would be:

1 - Allocate DMA
2 - Registers interrupt handler
3 - Enable device interrupts.

IvD

--nextPart1976923.1UqfYTiUxi
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBDjMK6aqndE37Em0gRAof8AKDQSn0ouW6mO+u1dagQlOGxykKPZACfY9bI
DBzUqBjE1ExmoI+3e6FuUpQ=
=I2Tq
-----END PGP SIGNATURE-----

--nextPart1976923.1UqfYTiUxi--
