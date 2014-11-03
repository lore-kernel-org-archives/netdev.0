From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 1/7] can: m_can: fix possible sleep in napi poll
Date: Mon, 03 Nov 2014 21:49:38 +0100
Message-ID: <5457EA62.5040906@pengutronix.de>
References: <1414579527-31100-1-git-send-email-b29396@freescale.com> <5457B517.8030805@pengutronix.de> <5457CB6B.3080002@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="SA9RjBfS4K5ROf2NLDpgiT2QTa1fOuGST"
Cc: wg@grandegger.com, varkabhadram@gmail.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Oliver Hartkopp <socketcan@hartkopp.net>,
	Dong Aisheng <b29396@freescale.com>, linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <5457CB6B.3080002@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--SA9RjBfS4K5ROf2NLDpgiT2QTa1fOuGST
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/03/2014 07:37 PM, Oliver Hartkopp wrote:
> you can omit the 'stable' tag as this driver just emerged in 3.18 - whi=
ch is
> currently in 3.18-rc3 state.

Thanks! fixed.

> If possible I would suggest to push all 7 patches via can/master as it =
is
> pretty bad to say "M_CAN was introduced in 3.18 but M_CAN with CAN FD i=
s
> working since 3.19".

Sorry, probably not, as CAN FD is a new feature. However we may talk to
David, as the m_can driver was introduced in 3.18 anyways, so it's
unlikely to break anything with this patch.

> This will produce confusion as the M_CAN core has built-in CAN FD suppo=
rt.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--SA9RjBfS4K5ROf2NLDpgiT2QTa1fOuGST
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUV+piAAoJECte4hHFiupUjtsQAKxZ25Y2W2dSg2dDwt1vSuqz
9zUjQEEH4eauW2WRog970igpehf7bZD3H9L8vhlXdmvah2uWT++ekg5r7oB8+rJj
86jSkma+LH7k/NZCkrEcwhz0huEEaRxSQMqF++Vb2GWxdbeOaBDSfNEs/DXOTU7F
moYRJ13eSpDJqT2ROm8eg/f+EfTgPIcUfP0NGxzksAX04HN6cwE4w0LG6Ska4DTT
IO2VdhO4XL7E8d3JwzBatXLBFf1HW/krll7U+Avlp5Fx/qPV4ANB31U7wt+vQGdk
qGWS1gjOgxoBMA36akrPUWVC1hQ08ZI+m25Sv3kp9MT1EPQkedbHGJthLbmmUm/g
gfE3OOWhkbcMlxquxwwt4EvUt+GeDg/xkBqjjlZbcZceJkWBmxTFswg52c0eKbw3
3UjYWtblacIHr3Az/ypaDAMhbOQSkCcKQ89SAS4KDIheLnZ2/7gGN6GX6tNs6rPO
sjRjHupOJQiqgq6F+Urr2GfdBj48PMlaWBdHEqWNUIQE3CdXU/ZB0+QP6ZMXgQ5P
7ppAGG3fIdesrBQgikNjt4pIb+8s4V+88ZtJyS37cqIVVunk3aAjAkB/E+3Q8nYs
waQDPOp1Iw9ZQDVM1jleV6hwE8JT5vPFFkb3PVli5h8gGDnewGyBCNnNUec0cl6L
NhJWAxYDBANax7yOobVV
=mK10
-----END PGP SIGNATURE-----

--SA9RjBfS4K5ROf2NLDpgiT2QTa1fOuGST--
